class LocationsMeasurements < Presenter
  def as_json(date)
    begin
      {
        date: date,
        locations:  @object.map { |o| LocationPresenter.new(o).as_json(o.wdates.first.measurements) }
      }
    rescue Exception => e
      # puts "(((((((((((((("
      # puts e.message
      {
      }
    end
  end
end
