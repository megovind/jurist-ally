class Util {
  static String capitalize(String input) {
    return input.isEmpty ? input : (input[0].toUpperCase() + input.substring(1));
  }

  static String inCaps(String input) {
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  static String allInCaps(String string) {
    return string.toUpperCase();
  }

  static String capitalizeFirstofEach(String string) {
    return string.isNotEmpty
        ? string
            .split(" ")
            .map((str) => str.isNotEmpty ? str[0].toUpperCase() + str.toLowerCase().substring(1) : str)
            .join(" ")
        : string;
  }
}
