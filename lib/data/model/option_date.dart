enum Option{
  usable,
  weekend,
  holiday,
  selected
}

class OptionDate {
  OptionDate(this.dateTime, {this.option = Option.usable, this.str = ''});

  final DateTime dateTime;
  Option option;
  String str;

  @override
  String toString() {
    return '$dateTime : $option : $str';
  }
}