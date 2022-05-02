part of theater.logging;

class DateTimeInserter {
  final String _pattern;

  final String _defaultDateTimePattern;

  DateTimeInserter(String pattern, String defaultDateTimePattern)
      : _pattern = pattern,
        _defaultDateTimePattern = defaultDateTimePattern;

  String insert(String template, DateTime dateTime) {
    var start = 0;

    while (true) {
      if (start <= template.length) {
        var timeStartIndex = template.indexOf(_pattern, start);

        if (timeStartIndex != -1) {
          var timeTemplateStartIndex = timeStartIndex + _pattern.length;

          if (template[timeTemplateStartIndex] == '(') {
            var timeTemplateEndIndex =
                template.indexOf(')', timeTemplateStartIndex);

            if (timeTemplateEndIndex != -1) {
              var timeTemplate = template.substring(
                  timeTemplateStartIndex + 1, timeTemplateEndIndex);

              template = template.replaceRange(
                  timeStartIndex,
                  timeTemplateEndIndex + 1,
                  DateFormat(timeTemplate).format(dateTime));

              start = timeTemplateEndIndex;
            } else {
              template.replaceFirst(_pattern, '');

              start = timeStartIndex + _pattern.length;
            }
          } else {
            template = template.replaceFirst(
                _pattern, DateFormat(_defaultDateTimePattern).format(dateTime));

            start = timeStartIndex + _pattern.length;
          }
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return template;
  }
}
