# Solofoodies iOS App

## Resumen
App iOS nativa para conectar foodies/creadores de contenido con restaurantes para colaboraciones.

## Stack
- Swift 5.9+, SwiftUI, iOS 16+
- Arquitectura: MVVM
- Networking: URLSession + async/await
- Auth: JWT en Keychain

## Dos tipos de usuario
- **Foodie**: Explora colaboraciones, aplica, chatea, deja ratings
- **Restaurant**: Crea colaboraciones, gestiona aplicaciones, chatea, deja ratings

## API Base
`https://api.solofoodies.com/api`

## Documentacion completa
Ver `docs/SOLOFOODIES_APP.md`

## Colores
- Primary: #E53935 (rojo)
- Lowblack: #333333
- Dgray: #666666
- Lgray: #F5F5F5

## Estructura del proyecto
```
Solofoodies/
├── App/                    # Entry point y navegacion principal
├── Features/               # Modulos por funcionalidad
│   ├── Auth/
│   ├── Foodies/
│   ├── Restaurants/
│   ├── Collaborations/
│   ├── Chat/
│   └── Ratings/
├── Core/                   # Infraestructura compartida
│   ├── Network/
│   ├── Services/
│   └── Storage/
├── Shared/                 # Componentes y estilos reutilizables
│   ├── Components/
│   └── Styles/
└── Resources/              # Assets, Info.plist
```

## Progreso
- [x] Setup proyecto Xcode
- [x] Repositorio GitHub
- [ ] Estructura de carpetas
- [ ] Core (APIClient, Keychain)
- [ ] Auth (Login, Registro, Verificacion)
- [ ] Navegacion principal
