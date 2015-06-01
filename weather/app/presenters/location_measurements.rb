class LocationMeasurements < Presenter
  def as_json(date, current_temp, current_cond)
    {
        date: date,
        current_temp: current_temp,
        current_cond: current_cond,
        measurements:  @object.map { |o| MeasurementPresenter.new(o).as_json }
    }
  end
end