class MeasurementPresenter < Presenter
  def as_json(*)
    {
        time: @object.timestamp.strftime('%H:%M:%S %p'),
        temp: @object.temperature.temp.to_s,
        precip: @object.rainfall.precip_mm,
        # wind_direction: @object.wind_direction.bearing,
        wind_direction: @object.wind_direction.direction,
        wind_speed: @object.wind_speed.speed.to_s
    }
  end
end