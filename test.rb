require 'orientdb4r'
require 'pp'

class Tester

  DB = 'vitals-test'

  CLIENT = Orientdb4r.client(host: `boot2docker ip`.strip)


  def run!
    drop_database!
    create_database!
    client.connect(database: DB, user: 'admin', password: 'admin')
    create_vertex_classes!
    create_edge_classes!
    create_vertexes!
    create_edges!
    client.disconnect
  end

  def create_database!
    client.create_database(database: DB, storage: :plocal, user: 'root', password: 'root', type: :graph)
  end

  def drop_database!
    if client.database_exists?(database: DB, user: 'root', password: 'root')
      client.delete_database(database: DB, user: 'root', password: 'root')
    end
  end

  def create_vertex_classes!
    %w(Professional InsurancePlan Contract Specialty Location).each do |vertex_name|
      client.create_class(vertex_name, extends: 'V') unless client.class_exists?(vertex_name)
    end
  end

  def create_edge_classes!
    %w(Provides Contracted Specializes Accepts Located).each do |edge_name|
      client.create_class(edge_name, extends: 'E') unless client.class_exists?(edge_name)
    end
  end

  def create_vertexes!
    @professional = create_vertex('Professional', name: 'bob')
    @chiropractor = create_vertex('Specialty', name: 'chiropractor')
    @heart = create_vertex('Specialty', name: 'heart')
    @insurance_plan = create_vertex('InsurancePlan', name: 'aetna')
    @location = create_vertex('Location', lat: 40.6676395, long: -73.981716, zip: 11215, name: 'hospital-bk')
    @contract = create_vertex('Contract')
  end

  def create_edges!
    create_edge('Provides', from: @professional, to: @contract)
    create_edge('Accepts', from: @contract, to: @insurance_plan)
    create_edge('Specializes', from: @contract, to: @heart)
    create_edge('Specializes', from: @contract, to: @chiropractor)
    create_edge('Located', from: @contract, to: @location)
  end

private

  def rid_from_results(results)
    results['result'].first['@rid']
  end

  def client
    CLIENT
  end

  def create_edge(class_name, from:, to:)
    client.command("CREATE EDGE #{class_name} FROM #{from} TO #{to}")
  end


  def create_vertex(class_name, attrs=nil)
    query = "CREATE VERTEX #{class_name}"
    if attrs
      #SQL injection!
      attrs_query = attrs.map {|k,v| "#{k}=#{v}"}
      query += " SET #{attrs_query.join(', ')}"
    end
    rid_from_results(client.command(query))
  end


end

Tester.new.run!