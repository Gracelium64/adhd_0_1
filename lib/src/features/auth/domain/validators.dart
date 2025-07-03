String abc = 'abcdefghijklmnopqrstuvwxyz';
String abcUpperCase = abc.toUpperCase();
String abcLowerUpperCase = abc + abcUpperCase;

String? userNameValidator(String? userInput) {
  if (userInput == null || userInput.isEmpty) {
    return "Please enter a username";
  }

  if (userInput.length >= 16) {
    return "Username must be less than 16 characters";
  }

  if (!abcLowerUpperCase.contains(userInput[0])) {
    return "Username must start with a letter";
  }

  if (userInput.contains(' ')) {
    return 'Empty spaces are not allowed in the User Name';
  }

  return null;
}
