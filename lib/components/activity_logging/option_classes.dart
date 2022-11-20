class Option {
  Option(this.option, this.isFavorite);
  
  String option;
  bool isFavorite;
}

class OptionWithHighlight extends Option {
  OptionWithHighlight(Option option, this.isSelected) : super(
    option.option, option.isFavorite
  );

  bool isSelected;
}