/// Validadores de formulario reutilizables para Juris Honoris.
/// Cada método retorna null si el valor es válido, o un String con el error.
class Validators {
  Validators._();

  /// Valida formato de correo electrónico.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresá un correo electrónico válido.';
    }
    return null;
  }

  /// Valida contraseña: mínimo 8 caracteres.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return null;
  }

  /// Valida que el campo no esté vacío.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }

  /// Valida número de teléfono hondureño: +504 seguido de 8 dígitos.
  /// Acepta con o sin el prefijo +504.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de teléfono es obligatorio.';
    }
    // Permite: +50498765432 | 98765432 | +504 9876-5432
    final clean = value.replaceAll(RegExp(r'[\s\-]'), '');
    final phoneRegex = RegExp(r'^(\+504)?[23789]\d{7}$');
    if (!phoneRegex.hasMatch(clean)) {
      return 'Ingresá un número válido (ej. +50498765432).';
    }
    return null;
  }

  /// Valida DNI hondureño: formato XXXX-XXXX-XXXXX (13 dígitos + 2 guiones).
  static String? dni(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de identidad es obligatorio.';
    }
    final dniRegex = RegExp(r'^\d{4}-\d{4}-\d{5}$');
    if (!dniRegex.hasMatch(value.trim())) {
      return 'Ingresá un DNI válido (formato XXXX-XXXX-XXXXX).';
    }
    return null;
  }
}
