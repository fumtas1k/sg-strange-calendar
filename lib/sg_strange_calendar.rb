require 'date'

class SgStrangeCalendar
  MONTH_NAMES = Date::ABBR_MONTHNAMES[1..12]
  DAY_ABBREVIATIONS = Date::ABBR_DAYNAMES.map { |name| name[0, 2] }
  DAY_NAMES_REPEATED = DAY_ABBREVIATIONS * 5 + DAY_ABBREVIATIONS[0, 2]

  private attr_reader :year, :today, :calendar

  def initialize(year, today = nil)
    @year = year
    @today = today
    @calendar = Array.new(12) { Array.new(DAY_NAMES_REPEATED.size) }

    (1..12).each do |month|
      start_weekday = Date.new(year, month, 1).wday
      days_in_month = Date.new(year, month, -1).day

      days_in_month.times do |day_index|
        calendar[month - 1][start_weekday + day_index] = day_index + 1
      end
    end
  end

  def generate(vertical: false)
    vertical ? generate_vertical : generate_horizontal
  end

  private

  def generate_horizontal
    @display_horizontal ||= begin
      result = calendar.map.with_index do |days, month_index|
        month_name = MONTH_NAMES[month_index].ljust(5)
        day_strings = days.map do |day|
          day.to_s.center(3)
        end
        month_name + day_strings.join
      end

      if today&.year == year
        month_index = today.month - 1
        day_str = sprintf("%2d", today.day).center(4)
        today_str = "[#{today.day}]".rjust(4)
        result[month_index].sub!(day_str, today_str)
      end

      generate_display_calendar(DAY_NAMES_REPEATED, result)
    end
  end

  def generate_vertical
    @display_vertical ||= begin
      result = calendar.transpose.map.with_index do |days, day_index|
        day_name = DAY_NAMES_REPEATED[day_index].ljust(5)
        day_strings = days.each_with_index.map do |day, month_index|
          day_str = if today&.year == year && today.month == month_index + 1 && today.day == day
                      "[#{day}]"
                    else
                      day.to_s.center(3)
                    end
          day_str.rjust(4)
        end
        day_name + day_strings.join
      end

      generate_display_calendar(MONTH_NAMES, result)
    end
  end

  def generate_display_calendar(headers, body)
    header = [year.to_s, *headers].join(' ')
    [header, *body.map(&:rstrip)].join("\n")
  end
end
