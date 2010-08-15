require 'helper'

class TestQtrefmovie < Test::Unit::TestCase
  should "create a reference movie matching the stored sample" do
    QTRefMovie
    movie = QTRefMovie::QTMovie.new [{:reference => "rtsp://127.0.0.1:80/test.mov",
                                      :data_rate => 'intranet',
                                      :cpu_speed => 'fast'},
                                     {:reference => "rtsp://127.0.0.1:80/test2.mov",
                                      :data_rate => 't1',
                                      :quality   => 650}]
    sample = File.read("test/sample.mov")
    assert_equal movie.to_s, sample
  end
end
