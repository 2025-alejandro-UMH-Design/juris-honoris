/// Strings de la aplicación en español (Honduras).
/// Centraliza todos los textos visibles al usuario.
class AppStrings {
  AppStrings._();

  // --- App ---
  static const String appName = 'Juris Honoris';
  static const String tagline = 'Tu asistente legal de confianza';

  // --- Botones comunes ---
  static const String continuar = 'Continuar';
  static const String guardar = 'Guardar';
  static const String cancelar = 'Cancelar';
  static const String cerrar = 'Cerrar';
  static const String aceptar = 'Aceptar';
  static const String reintentar = 'Reintentar';
  static const String eliminar = 'Eliminar';
  static const String editar = 'Editar';
  static const String agregar = 'Agregar';
  static const String listo = 'Listo';
  static const String ver = 'Ver';
  static const String salir = 'Salir';
  static const String atras = 'Atrás';
  static const String siguiente = 'Siguiente';

  // --- Mensajes de error genéricos ---
  static const String errorGenerico =
      'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
  static const String errorConexion =
      'Sin conexión a internet. Verifica tu red e inténtalo de nuevo.';
  static const String errorServidor =
      'Error en el servidor. Por favor, inténtalo más tarde.';
  static const String errorNoEncontrado =
      'No se encontró el recurso solicitado.';
  static const String errorSesionExpirada =
      'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.';
  static const String errorCampoRequerido = 'Este campo es obligatorio.';
  static const String errorFormatoInvalido = 'El formato ingresado no es válido.';

  // --- Autenticación ---
  static const String iniciarSesion = 'Iniciar sesión';
  static const String cerrarSesion = 'Cerrar sesión';
  static const String registrarse = 'Registrarse';
  static const String correoElectronico = 'Correo electrónico';
  static const String contrasena = 'Contraseña';
  static const String confirmarContrasena = 'Confirmar contraseña';
  static const String nombreCompleto = 'Nombre completo';
  static const String telefono = 'Teléfono';
  static const String olvidasteTuContrasena = '¿Olvidaste tu contraseña?';
  static const String recuperarContrasena = 'Recuperar contraseña';
  static const String yaTenesUentaCuenta = '¿Ya tenés cuenta? ';
  static const String noTenesUentaCuenta = '¿No tenés cuenta? ';
  static const String ingresoExitoso = 'Ingreso exitoso. Bienvenido/a.';
  static const String errorCredenciales =
      'Correo o contraseña incorrectos.';
  static const String errorCorreoEnUso =
      'Este correo ya está registrado.';
  static const String errorContrasenaMuyCorta =
      'La contraseña debe tener al menos 8 caracteres.';
  static const String errorContrasenasNoCoinciden =
      'Las contraseñas no coinciden.';
  static const String errorCorreoInvalido =
      'Ingresá un correo electrónico válido.';
  static const String errorTelefonoInvalido =
      'Ingresá un número de teléfono válido (ej. +50498765432).';
  static const String errorDniInvalido =
      'Ingresá un DNI válido (formato XXXX-XXXX-XXXXX).';

  // --- Chat IA ---
  static const String chatIa = 'Chat con IA';
  static const String chatBienvenida =
      'Hola, soy tu asistente legal. ¿En qué te puedo ayudar hoy?';
  static const String chatEscribeMensaje = 'Escribí tu consulta...';
  static const String chatEnviar = 'Enviar';
  static const String chatNuevaChatConversacion = 'Nueva conversación';
  static const String chatHistorial = 'Historial de chats';
  static const String chatPensando = 'Pensando...';
  static const String chatSinHistorial =
      'Aún no tenés conversaciones. ¡Hacé tu primera consulta!';
  static const String chatErrorRespuesta =
      'No se pudo obtener una respuesta. Verificá tu conexión.';
  static const String chatCopiado = 'Mensaje copiado al portapapeles.';
  static const String chatLimpiar = 'Limpiar chat';
  static const String chatLimpiarConfirm =
      '¿Estás seguro/a de que querés limpiar la conversación?';

  // --- Panel de administración ---
  static const String adminPanel = 'Panel de Administración';
  static const String adminPin = 'PIN de administrador';
  static const String adminIngresarPin = 'Ingresá el PIN de administrador';
  static const String adminPinIncorrecto = 'PIN incorrecto. Inténtalo de nuevo.';
  static const String adminCambiarPin = 'Cambiar PIN';
  static const String adminPinActual = 'PIN actual';
  static const String adminNuevoPin = 'Nuevo PIN';
  static const String adminConfirmarPin = 'Confirmar nuevo PIN';
  static const String adminPinCambiado = 'PIN actualizado correctamente.';
  static const String adminConfiguracionIA = 'Configuración de IA';
  static const String adminProveedores = 'Proveedores de IA';
  static const String adminApiKey = 'API Key';
  static const String adminModelo = 'Modelo';
  static const String adminActivar = 'Activar';
  static const String adminGuardarConfig = 'Guardar configuración';
  static const String adminConfigGuardada =
      'Configuración guardada correctamente.';
  static const String adminErrorApiKey = 'Ingresá una API Key válida.';
  static const String adminProveedorActivo = 'Proveedor activo';
  static const String adminEstadisticas = 'Estadísticas de uso';
  static const String adminUsuarios = 'Gestión de usuarios';
  static const String adminNuevoUsuario = 'Nuevo usuario';

  // --- Navegación ---
  static const String navInicio = 'Inicio';
  static const String navChatIa = 'Chat IA';
  static const String navTareas = 'Tareas';
  static const String navDossier = 'Expediente';
  static const String navPerfil = 'Perfil';

  // --- Tareas ---
  static const String tareas = 'Tareas';
  static const String nuevaTarea = 'Nueva tarea';
  static const String editarTarea = 'Editar tarea';
  static const String tituloTarea = 'Título';
  static const String descripcionTarea = 'Descripción';
  static const String categoriaTarea = 'Categoría';
  static const String prioridadTarea = 'Prioridad';
  static const String fechaVencimiento = 'Fecha de vencimiento';
  static const String tareaCompletada = 'Tarea completada';
  static const String sinTareas =
      'No tenés tareas pendientes. ¡Creá una nueva!';

  // --- Dossier ---
  static const String dossier = 'Dossier';
  static const String nuevoExpediente = 'Nuevo expediente';
  static const String sinExpedientes =
      'No tenés expedientes. ¡Creá el primero!';

  // --- Estados vacíos y carga ---
  static const String cargando = 'Cargando...';
  static const String sinResultados = 'Sin resultados';
  static const String sinConexion = 'Sin conexión';
}
