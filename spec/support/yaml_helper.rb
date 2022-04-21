module YamlHelper
  # http://qiita.com/vivid_muimui/items/5e0bc229a688afefbce2
  def yaml_to_hash(filepath)
    File.open(filepath) do |raw|
      YAML.load(raw)
    end
  end
end
