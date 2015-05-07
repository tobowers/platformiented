require 'platformiented/models/edges'

class Professional
  include Oriented::Vertex

  property :name

  has_one(:contract).relationship(Contract)

end

class InsurancePlan

end