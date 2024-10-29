require "date"

class SgStrangeCalendar

  MONTHNAMES = Date::ABBR_MONTHNAMES[1..12]
  DAYNAMES = Date::ABBR_DAYNAMES.map { _1[0, 2] }.then { _1 * 5 + _1[0, 2] }

  def initialize(year, today = nil)
    @year = year
    @today = today

    @calendar = Array.new(12) { Array.new(DAYNAMES.size) }
    1.upto(12) do |month|
      start_wday = Date.new(year, month, 1).wday
      end_day = Date.new(year, month, -1).day
      @calendar[month - 1][start_wday, end_day] = [*1..end_day]
    end
  end

  def generate(vertical: false) = vertical ? generate_vertical : generate_horizontal

  private
  def generate_horizontal
    @display_horizontal ||= @calendar.map.with_index do |days, i|
      month = MONTHNAMES[i].ljust(5, " ")
      days.each_with_object([month]) do |day, acc|
        acc << day.to_s.center(3)
      end.join
    end.tap do |result|
      next unless @today&.year == @year
      result[@today.month - 1].sub!(sprintf("%2d", @today.day).center(4), "[#{@today.day}]".rjust(4))
    end.unshift([@year, *DAYNAMES].join(" ")).map(&:rstrip).join("\n")
  end

  def generate_vertical
    @display_vertical ||= @calendar.transpose.map.with_index do |days, i|
      day_name = DAYNAMES[i].ljust(5, " ")
      days.each_with_index.each_with_object([day_name]) do |(day, j), acc|
        acc << (j + 1 == @today&.month && day == @today&.day ? "[#{day}]" : day.to_s.center(3)).rjust(4)
      end.join
    end.unshift([@year, *MONTHNAMES].join(" ")).map(&:rstrip).join("\n")
  end
end
