# Hallazgos: duplicación en el cálculo de precio por partida

## 2.1 Fragmentos duplicados

**Fragmento 1**
- Archivo: `lib/services/carrito_service.dart`
- Función: `CarritoService.calcularSubtotalPartida(Partida, TipoCliente)`
- Se usa para mostrar el subtotal en vivo mientras el cliente o el mostrador
  arman el pedido (partida por partida, antes de confirmarlo).

**Fragmento 2**
- Archivo: `lib/services/pedido_service.dart`
- Función: `PedidoService.calcularTotalPedido(Pedido)` (dentro del ciclo
  `for (final partida in pedido.partidas)`)
- Se usa para recalcular el total al momento de confirmar el pedido y para
  el corte del día, sin confiar en el subtotal que trae el carrito.

**Qué se repite exactamente**

En ambos lugares aparece, letra por letra, el mismo árbol de condicionales
anidados que decide el precio unitario:

```dart
if (tipoCliente == TipoCliente.mayorista) {
  if (partida.cantidad >= 10) {
    precioUnitario = partida.planta.precioBase * 0.80;
  } else {
    precioUnitario = partida.planta.precioBase * 0.90;
  }
  if (promocionActiva) {
    precioUnitario = precioUnitario * 0.95;
  }
} else {
  if (promocionActiva) {
    precioUnitario = partida.planta.precioBase * 0.85;
  } else {
    precioUnitario = partida.planta.precioBase;
  }
}
```

Es decir, la regla de negocio completa — descuento por tipo de cliente
(general/mayorista), umbral de volumen (`cantidad >= 10`) y descuento de
promoción de temporada, incluida la combinación mayorista + promoción — vive
copiada en dos servicios distintos. Nació así porque, sin servidor propio
todavía, cada capa necesitaba su propio número: el carrito para mostrarlo en
vivo, el pedido para no confiar en lo que trae el carrito al confirmar. La
señal de que es duplicación real y no coincidencia: cualquier cambio en un
porcentaje o en el umbral de volumen (algo que "crece cada mes", como dice el
enunciado) hay que aplicarlo dos veces, en dos archivos, y es fácil que se
apliquen distinto y el subtotal del carrito deje de coincidir con el total
del pedido confirmado.

## 2.2 Patrón aplicado y por qué

**Patrón: Strategy.**

Se introdujo `EstrategiaPrecio` (interfaz) con dos implementaciones,
`PrecioGeneralStrategy` y `PrecioMayoristaStrategy`, y un contexto
`CalculadoraPrecio` que elige la estrategia según `TipoCliente` y expone un
único método `calcularPrecioPartida(...)`. `CarritoService` y
`PedidoService` dejan de decidir el precio: ambos delegan en
`CalculadoraPrecio`, que es ahora la única fuente de verdad.

**Por qué Strategy y no otra cosa:**

- *Extraer una función compartida* (sin patrón) habría quitado la
  duplicación literal, pero el problema de fondo no es solo la copia: es que
  "una sola función con condicionales anidados que crece cada mes" ya es
  difícil de mantener incluso en un solo lugar. Strategy separa cada regla de
  negocio (general, mayorista, y la que exista mañana: VIP, empleados, etc.)
  en su propia clase, así que agregar un tipo de cliente nuevo es agregar una
  clase, no abrir el condicional existente y arriesgar romper las reglas ya
  probadas (abierto a extensión, cerrado a modificación).
- *Decorator* encajaría si la promoción fuera un envoltorio independiente del
  tipo de cliente, pero aquí el descuento de promoción no es uniforme: para
  mayorista es un 5% adicional sobre el precio ya descontado por volumen,
  para general es un 15% sobre el precio base. Modelarlo como decorador
  separado habría obligado a que el decorador conociera reglas de cada
  estrategia, es decir, la misma mezcla que se quiere evitar.
- *Chain of Responsibility* no aplica: no hay una cadena de manejadores que
  se pasan la solicitud hasta que uno la resuelve, hay una sola decisión
  mutuamente excluyente (el tipo de cliente), que es exactamente el caso de
  uso de Strategy.
- Cada estrategia queda además probada de forma aislada (ver
  `test/calculadora_precio_test.dart`), algo que con el condicional anidado
  original requería armar combinaciones completas para cubrir una sola
  rama.

**Componente afectado:** la calculadora de precio de partida, consumida por
`CarritoService` y `PedidoService`.
