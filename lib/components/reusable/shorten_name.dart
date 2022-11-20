String shortenName(String name, [int maxLength = 15]) {
  if (name.length > maxLength) {
    return '${name.substring(0, maxLength-3)}...';
  }

  return name;
}