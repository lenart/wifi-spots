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
    Spot.search @query, :page => @page, :per_page => 20
  end
  
  private
  
    def normalize
    end
  
end