class Validators {
  /// 🔹 No vacío
  static String? validateNotEmpty(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName no puede estar vacío';
    }
    return null;
  }

  /// 🔹 Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo no puede estar vacío';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Correo electrónico no válido';

    return null;
  }

  /// 🔹 Contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña no puede estar vacía';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  /// 🔹 Nombre
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nombre no puede estar vacío';
    if (value.trim().length < 3) return 'Debe contener al menos 3 caracteres';
    return null;
  }

  /// 🔹 Teléfono (obligatorio en el registro)
  ///
  /// Acepta:
  ///   - 9 dígitos (España)
  ///   - +34 600 123 456
  ///   - 600-123-456
  ///   - (600) 123 456
  ///
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Ingresa un número de teléfono";
    }

    // Acepta dígitos, espacios, +, -, paréntesis
    final phoneRegex = RegExp(r'^[0-9 +()\-]{7,15}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return "Teléfono no válido";
    }

    return null;
  }

  /// 🔹 Precio numérico válido
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa un precio';
    final num? price = num.tryParse(value);
    if (price == null || price <= 0) return 'Precio inválido';
    return null;
  }

  /// 🔹 Duración en minutos (entero)
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa la duración';
    final int? min = int.tryParse(value);
    if (min == null || min <= 0) return 'Duración inválida';
    return null;
  }
}
