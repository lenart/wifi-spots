class Search
  
  attr_reader :query, :page
  
  def initialize(params)
    @query = params[:q]
    @page = (params[:page] || 1).to_i
  end
  
  def blank?
    @query.blank?
  end
  
  def run
    # Application-wide search
    # ThinkingSphinx.search @query, :classes => [Spot, Comment]
    raise Search::EmptyQuery if self.blank?
    
    results = Spot.search @query, :page => @page, :per_page => 20
    raise Search::NoResults.new(self.query) if results.empty?
    
    results
  end
  
  private
  
    def normalize
      # TODO Search for "/wifi blizu (.+)/" and preform geo search
      #      change lj => ljubljana, ce => celje etc.
      #      change %w(wi-fi net internet) => wifi
    end
  
end

class Search::EmptyQuery < ArgumentError
  def initialize
    Rails.logger.warn "Empty search attempted."
  end
end

class Search::NoResults < RangeError
  attr_reader :query
  def initialize(query)
    @query = query
  end
end