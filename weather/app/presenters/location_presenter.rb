class LocationPresenter < Presenter
  def as_json(measurements_list = nil)
    if measurements_list.nil?
      {
        id: @object.loc_id,
        lat: @object.lat.to_s,
        lon: @object.lon.to_s,
        last_update: @object.updated_at.strftime('%H:%M %d-%m-%Y')
      }
    else
      {
        id: @object.loc_id,
        lat: @object.lat.to_s,
        lon: @object.lon.to_s,
        last_update: @object.updated_at.strftime('%H:%M %d-%m-%Y'),
        measurements: measurements_list.map { |o| MeasurementPresenter.new(o).as_json }
      }
    end
  end
end