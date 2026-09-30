# Vivero Xochicalco

App móvil (Flutter) para levantar pedidos del vivero Xochicalco (Temixco)
desde el mostrador o desde el teléfono del cliente. Mientras no hay servidor
disponible, el catálogo y las reglas de precio corren sobre datos locales.

## Contenido del repo

```
lib/
  models/
    planta.dart          Planta del catálogo (id, nombre, precio base, existencia)
    partida.dart          Una línea del pedido: planta + cantidad
    pedido.dart            Pedido completo: partidas, tipo de cliente, estado
                           y total cobrado al confirmar
    tipo_cliente.dart     Enum: general | mayorista
  data/
    catalogo_local.dart   Catálogo de prueba (reemplazo temporal de la API propia del vivero)
  services/
    carrito_service.dart      Arma el pedido y calcula el subtotal en vivo
    pedido_service.dart       Registra pedidos, confirma/rechaza, corte del día
    promocion_service.dart    Bandera de promoción de temporada activa
    pricing/
      estrategia_precio.dart          Interfaz Strategy para el precio unitario
      precio_general_strategy.dart    Regla de precio para cliente general
      precio_mayorista_strategy.dart  Regla de precio para cliente mayorista
      calculadora_precio.dart         Contexto: elige la estrategia y es la
                                       única fuente de verdad del precio de
                                       una partida
  screens/
    catalogo_screen.dart  Cliente/mostrador: tipo de cliente, cantidades,
                          subtotal en vivo y envío del pedido
    pedidos_screen.dart   Encargada: promoción de temporada, confirmar/rechazar
                          pedidos y corte del día
    formato.dart          Formato de precios y nombres para la UI
  main.dart               Contenedor con las pestañas Catálogo y Pedidos

test/
  calculadora_precio_test.dart   Verifica que el precio por partida se
                                 mantiene igual para cada combinación de
                                 tipo de cliente y promoción
  pedido_service_test.dart       El corte del día suma lo cobrado al confirmar,
                                 aunque la promoción cambie después
  flujo_pedido_test.dart         Recorre la UI: armar, enviar y confirmar un
                                 pedido y revisar el corte

hallazgos.md              Duplicación encontrada en el cálculo de precio,
                           patrón aplicado (Strategy) y justificación
```

## Historia de las ramas

- `master`: prototipo inicial. El precio de una partida se calculaba con un
  condicional anidado (cliente general / mayorista / promoción de temporada)
  copiado por separado en `CarritoService` y `PedidoService`.
- `s02-patrones`: refactor con el patrón **Strategy** que elimina esa
  duplicación (`lib/services/pricing/`). El detalle está en `hallazgos.md`.
- `s03-flujo-pedidos`: UI del flujo completo (catálogo con cantidades y tipo
  de cliente, vista de la encargada con promoción, confirmar/rechazar y corte
  del día). El total se fija al confirmar para que el corte no cambie si la
  promoción se activa o desactiva después.

## Cómo correrlo

```bash
flutter pub get
flutter run        # levanta la app (catálogo y pedidos) con datos locales
flutter test        # corre las pruebas de precio, pedidos y flujo de UI
flutter analyze     # análisis estático
```
