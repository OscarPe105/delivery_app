# 🔥 Solución: Índices de Firestore para Chat

## Problema
El error `failed-precondition` indica que Firestore requiere índices compuestos para la consulta de conversaciones.

## Solución: Crear Índices Manualmente

### Opción 1: Usar el enlace del error (Más rápido)

Cuando veas el error, haz clic en el enlace que aparece en el mensaje. Firebase te llevará directamente a la consola para crear los índices necesarios.

El enlace será algo como:
```
https://console.firebase.google.com/v1/r/project/delivery-app-15f53/firestore/indexes?create_index=...
```

### Opción 2: Crear índices manualmente en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: `delivery-app-15f53`
3. Ve a **Firestore Database** → **Índices**
4. Haz clic en **Crear índice**
5. Crea estos dos índices:

#### Índice 1:
- **Colección ID**: `conversations`
- **Campos a indexar**:
  1. `participant1Id` - Ascendente
  2. `updatedAt` - Descendente
- Haz clic en **Crear**

#### Índice 2:
- **Colección ID**: `conversations`
- **Campos a indexar**:
  1. `participant2Id` - Ascendente
  2. `updatedAt` - Descendente
- Haz clic en **Crear**

### Tiempo de construcción
Los índices pueden tardar varios minutos en construirse. Una vez completados, el error desaparecerá automáticamente.

## Solución Alternativa (Código)

Si prefieres evitar los índices compuestos, puedes modificar el código para usar dos consultas separadas (ya implementado en una versión anterior del código).
