$LOAD_PATH.unshift 'lib'
require 'rube_post'

CFG = YAML.load(File.read('spec/config.yml'))