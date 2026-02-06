 Plan: Desktop Icons + Inbox App (eliminar Taskbar)

 Resumen

 Eliminar la taskbar inferior. Reemplazarla con íconos de escritorio (Shop, Inbox) estilo Mac clásico y un Inbox que lista los leads disponibles. Créditos y trace se mueven a la barra de menú superior.

 Archivos Nuevos (4)

 1. src/ui/desktop_icon.lua — Ícono de escritorio

 - Clase DesktopIcon: id, x, y, label, callback, badge_count, hover
 - Área de ícono 48x48 con borde biselado + label centrado abajo
 - Placeholder visual: rectángulo gris con letra inicial (sin imágenes por ahora)
 - Badge: círculo rojo con número blanco en esquina superior-derecha (para Inbox)
 - Hover: borde highlight

 2. src/ui/desktop_manager.lua — Gestor de íconos

 - Contiene array de DesktopIcon
 - Métodos: addIcon, getIcon, mousepressed, update (hover), draw
 - Click handling retorna true/false para propagación

 3. src/ui/notification.lua — Notificaciones flotantes

 - Reemplaza taskbar:notify()
 - NotificationManager con array de notificaciones activas
 - Cada notificación: texto, timer 3s, fade out en último segundo
 - Posición: centro-abajo de pantalla, apilan hacia arriba
 - Apariencia: caja blanca con borde biselado, texto negro, sombra

 4. src/ui/inbox_window.lua — Fábrica de ventana Inbox

 - Función createInboxWindow(lead_system, on_lead_click) → retorna Window
 - Título: "Inbox"
 - Contenido: lista de leads con botones dinámicos (patrón igual al Shop)
 - Cada lead: [RARITY] Lead #ID — min-max CR + botón "Open"
 - Estado vacío: "No leads available" centrado en gris
 - Tamaño: 380x300, posición centro-izquierda

 Archivos a Modificar (3)

 5. src/ui/theme.lua

 - drawMenuBar(sw, economy, trace): agregar créditos (derecha) y mini trace bar al menu bar
 - Nuevo helper drawBadge(x, y, count): círculo rojo + número blanco

 6. src/ui/window.lua

 - Quitar constraint de 40px de taskbar en drag clamping (línea 95)

 7. main.lua — GameState

 - Quitar: import Taskbar, self.taskbar, toda referencia a taskbar
 - Agregar imports: DesktopManager, NotificationManager, createInboxWindow, DesktopIcon
 - GameState.new(): crear desktop_manager + notification_manager + 2 íconos (Shop, Inbox)
 - Nuevo método: toggleInbox() — abre/cierra ventana inbox, igual que toggleShop
 - 8 llamadas self.taskbar:notify(...) → self.notification_manager:notify(...)
 - update(): agregar desktop_manager:update, notification_manager:update; quitar taskbar:update; actualizar badge del inbox icon cuando llegan leads
 - draw(): dibujar desktop icons antes de ventanas, notifications después de todo; quitar taskbar:draw; pasar economy/trace a drawMenuBar
 - mousepressed(): quitar manejo de taskbar; agregar check de windows primero, luego desktop_manager:mousepressed; agregar tracking de inbox_open
 - keypressed(): agregar Ctrl+I para toggle inbox

 Flujo de Clicks (nuevo)

 1. y ≤ MENU_BAR_HEIGHT → ignorar
 2. window_manager:mousepressed() → si consume, return
 3. desktop_manager:mousepressed() → si consume, return
 4. Click en desktop vacío → nada

 Flujo de Leads (nuevo)

 1. LeadSystem:update() → spawns lead
 2. notification_manager:notify("New lead...") + actualiza badge en ícono Inbox
 3. Usuario clickea ícono Inbox → abre ventana Inbox
 4. Ventana Inbox muestra lista → usuario clickea botón "Open" de un lead
 5. Callback llama openDecrypterWindow(lead) → abre ventana HexDecrypter (sin cambios)

 Orden de Implementación

 1. src/ui/desktop_icon.lua (nuevo)
 2. src/ui/desktop_manager.lua (nuevo)
 3. src/ui/notification.lua (nuevo)
 4. src/ui/inbox_window.lua (nuevo)
 5. src/ui/theme.lua (modificar drawMenuBar + agregar drawBadge)
 6. src/ui/window.lua (quitar constraint taskbar)
 7. main.lua (integración completa: quitar taskbar, conectar todo)

 Verificación

 - love . sin errores
 - Desktop muestra 2 íconos (Shop, Inbox) en esquina superior-derecha
 - Click en Shop → abre ventana Shop (funcional)
 - Click en Inbox → abre ventana con lista de leads
 - Leads aparecen en inbox cada 5s; badge se actualiza
 - Click "Open" en lead del inbox → abre HexDecrypter
 - Notificaciones flotan en centro-abajo y desaparecen en 3s
 - Menu bar muestra créditos y trace bar
 - No hay taskbar abajo
 - Ventanas se arrastran por todo el espacio vertical
 - Raid, save, extract, abort — todo funcional
 - Ctrl+S = Shop, Ctrl+I = Inbox, F5 = Save
                                                                                                                                                                                                                "✳ Desktop UI customiz" 11:19 06-feb.-26