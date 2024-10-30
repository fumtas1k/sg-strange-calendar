require 'date'

class SgStrangeCalendar
  # 1月から12月までの省略月名
  MONTH_NAMES = Date::ABBR_MONTHNAMES[1..12]

  # 曜日の省略名（最初の2文字）
  DAY_NAMES_REPEATED = begin
    short_day_names = Date::ABBR_DAYNAMES.map { |name| name[0, 2] }
    # 最大で 37 要素（7日 * 5週 + 2日）になるように繰り返す
    short_day_names * 5 + short_day_names[0, 2]
  end

  private attr_reader :year, :today, :calendar

  def initialize(year, today = nil)
    @year = year
    @today = today

    @calendar = Array.new(12) { Array.new(DAY_NAMES_REPEATED.size) }

    (1..12).each do |month|
      start_wday = Date.new(year, month, 1).wday
      day_count = Date.new(year, month, -1).day

      day_count.times { calendar[month - 1][start_wday + _1] = _1 + 1 }
    end
  end

  # カレンダーを生成（縦向きまたは横向き）
  def generate(vertical: false)
    vertical ? generate_vertical : generate_horizontal
  end

  private

  # 横向きのカレンダーを生成
  def generate_horizontal
    @display_horizontal ||= begin
      result = calendar.map.with_index do |days, i|
        month = MONTH_NAMES[i].ljust(5)
        day_strings = days.map do |day|
          day.to_s.center(3)
        end
        month + day_strings.join
      end

      if today && today.year == year
        month_index = today.month - 1
        day_str = sprintf("%2d", today.day).center(4)
        today_str = "[#{today.day}]".rjust(4)
        result[month_index].sub!(day_str, today_str)
      end

      generate_display_calendar(DAY_NAMES_REPEATED, result)
    end
  end

  # 縦向きのカレンダーを生成
  def generate_vertical
    @display_vertical ||= begin
      result = calendar.transpose.map.with_index do |days, i|
        day_name = DAY_NAMES_REPEATED[i].ljust(5)
        day_strings = days.each_with_index.map do |day, j|
          day_str = if today&.year == year && today&.month == j + 1 && today.day == day
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

  # カレンダーの表示形式を生成
  def generate_display_calendar(header_element, body_element)
    header = [year.to_s, *header_element].join(' ')
    [header, *body_element.map(&:rstrip)].join("\n")
  end
end
