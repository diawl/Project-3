class LocationsPresenter < Presenter
  def as_json(*)
    {
        date: Time.now.strftime('%d-%m-%Y'),
        locations:  @object.map { |o| LocationPresenter.new(o).as_json  }
    }
  end
end