# Copyright (c) 2010 Jonathan Block
# jonblock@jonblock.com
# Based on PHPRefMovie Copyright (C) 2003 Juergen Enge (GPL V2 or later)
# http://www.phpclasses.org/browse/file/7719.html
# juergen@info-age.net
#
# Translated to Ruby 2010 by Jonathan Block
# Most of the code design and code comments are Juergen's.
# I just translated it to Ruby, simplified usage, and made it a Ruby Gem.
# Please see the README.


module QTRefMovie

  # USAGE
  def qt_sample_code
    ref_movie = QTRefMovie.new
    
    data_reference = QTDataReference.new "rtsp://127.0.0.1:80/test.mov"
    data_rate = QTDataRate.new("intranet")
    cpu_speed = QTCPUSpeed.new("fast")
    
    movie_descriptor = QTRefMovieDescriptor.new
    movie_descriptor.add_chunk data_reference
    movie_descriptor.add_chunk data_rate
    movie_descriptor.add_chunk cpu_speed
    
    ref_movie.add_chunk movie_descriptor
    
    data_reference = QTDataReference.new "rtsp://127.0.0.1:80/test2.mov"
    data_rate = QTDataRate.new("t1")
    cpu_speed = QTQuality.new(650)
    
    movie_descriptor = QTRefMovieDescriptor.new
    movie_descriptor.add_chunk data_reference
    movie_descriptor.add_chunk data_rate
    movie_descriptor.add_chunk cpu_speed
    
    ref_movie.add_chunk movie_descriptor
    
    movie = QTMovie.new
    movie.add_chunk ref_movie
    movie.to_s
  end
  
  def qt_easier_sample_code
    movie = QTMovie.new [{:reference => "rtsp://127.0.0.1:80/test.mov",
                          :data_rate => 'intranet',
                          :cpu_speed => 'fast'},
                         {:reference => "rtsp://127.0.0.1:80/test2.mov",
                          :data_rate => 't1',
                          :quality   => 650}]
    movie.to_s
  end


  class QTBase
    def initialize
      @list = []
      @type = '    '
    end
    
    def add_chunk( chunk, pos = -1 )
      if pos < 0
        @list << chunk
      else
        @list[pos] = chunk
      end
    end
    
    def size
      size = 0
      (0..(@list.count-1)).each do |i|
        size += @list[i].size
      end
      size += 2*4
    end
    
    def to_s
      str = [size].pack('N')
      str += @type
      if @list.count > 0
        (0..(@list.count-1)).each do |i|
          str += @list[i].to_s
        end
      end
      str
    end
  end


  # The Movie Atom
  # You use movie atoms to specify the information that defines a movie-that is, the
  # information that allows your application to understand the data that is stored in the
  # movie data atom. The movie atom normally contains a movie header atom, which defines
  # the time scale and duration information for the entire movie, as well as its display
  # characteristics. In addition, the movie atom contains a track atom for each track in
  # the movie.
  # 
  # The movie atom has an atom type of 'moov'. It contains other types of atoms, including
  # at least one of three possible parent atoms-the movie header atom ('mvhd'), the
  # compressed movie atom ('cmov'), or a reference movie atom ('rmra'). An uncompressed
  # movie atom can contain both a movie header atom and a reference movie atom, but it
  # must contain at least one of the two. It can also contain several other atoms, such
  # as a clipping atom ( 'clip'), one or more track atoms ( 'trak'), a color table atom
  # ( 'ctab'), and a user data atom 'udta').
  # 
  # Compressed movie atoms and reference movie atoms are discussed separately. This
  # section describes normal uncompressed movie atoms.
  # 
  # A movie atom may contain the following information.
  # 
  # 
  # Size
  # The number of bytes in this movie atom.
  # 
  # Type
  # The type of this movie atom; this field must be set to 'moov'.
  # 
  # Movie header atom
  # See "Movie Header Atoms" for more information.
  # 
  # Movie clipping atom
  # See "Clipping Atoms" for more information.
  # 
  # Track list atoms
  # See "Track Atoms" for details on track atoms and their associated atoms.
  # 
  # User data atom
  # See "User Data Atoms" for more infomation about user data atoms.
  # 
  # Color table atom
  # See"Color Table Atoms" for a discussion of the color table atom.
  # 
  # Compressed movie atom
  # See "Compressed Movie Resources" for a discussion of compressed movie atoms.
  # 
  # Reference movie atom
  # See "Reference Movies" for a discussion of reference movie atoms.

  class QTMovie < QTBase
    def initialize( options = nil )
      super()
      @type = 'moov'
      unless options.nil?
        ref_movie = QTRefMovie.new
        options.each do |opt|
          movie_descriptor = QTRefMovieDescriptor.new
          movie_descriptor.add_chunk QTDataReference.new opt[:reference] unless opt[:reference].nil?
          movie_descriptor.add_chunk QTDataRate.new      opt[:data_rate] unless opt[:data_rate].nil?
          movie_descriptor.add_chunk QTCPUSpeed.new      opt[:cpu_speed] unless opt[:cpu_speed].nil?
          movie_descriptor.add_chunk QTQuality.new       opt[:quality  ] unless opt[:quality  ].nil?
          ref_movie.add_chunk movie_descriptor
        end
        add_chunk ref_movie
      end
    end
    
    #def set_ref_movie( qt_ref_movie )
    #  add_chunk qt_ref_movie, 0
    #end
  end


  # Reference Movie Atom
  # A reference movie atom contains references to one or more movies. It can optionally
  # contain a list of system requirements in order for each movie to play, and a quality
  # rating for each movie. It is typically used to specify a list of alternate movies to
  # be played under different conditions.
  # 
  # A reference movie atom's parent is always a movie atom ('moov'). Only one reference
  # movie atom is allowed in a given movie atom.
  # 
  # 
  # A reference movie atom may contain the following information.
  # 
  # Size
  # The number of bytes in this reference movie atom.
  # 
  # Type
  # The type of this atom; this field must be set to 'rmra'.
  # 
  # Reference movie descriptor atom
  # A reference movie atom must contain at least one reference movie descriptor atom, and
  # typically contains more than one. See "Reference Movie Descriptor Atom" for more
  # information.
  
  class QTRefMovie < QTBase
    def initialize
      super
      @type = 'rmra'
    end
  end


  # Reference Movie Descriptor Atom
  # Each reference movie descriptor atom contains other atoms that describe where a
  # particular movie can be found, and optionally what the system requirements are to
  # play that movie, as well as an optional quality rating for that movie.
  # 
  # A reference movie descriptor atom's parent is always a movie reference atom ('rmra').
  # Multiple reference movie descriptor atoms are allowed in a given movie reference atom,
  # and more than one is usually present.
  # 
  # A reference movie descriptor atom may contain the following information.
  # 
  # 
  # 
  # Size
  # The number of bytes in this reference movie descriptor atom.
  # 
  # Type
  # The type of this atom; this field must be set to 'rmda'.
  # 
  # Data reference atom
  # Each reference movie atom must contain exactly one data reference atom. See "Data
  # Reference Atoms" for more information.
  # 
  # Data rate atom
  # A reference movie atom may contain an optional data rate atom. Only one data rate
  # atom can be present. See "Data Rate Atom" for more information.
  # 
  # CPU speed atom
  # A reference movie atom may contain an optional CPU speed atom. Only one CPU speed
  # atom can be present. See "CPU Speed Atom" for more information.
  # 
  # Version check atom
  # A reference movie atom may contain an optional version check atom. Multiple version
  # check atoms can be present. See "Version Check Atom" for more information.
  # 
  # Component detect atom
  # A reference movie atom may contain an optional component detect atom. Multiple
  # component detect atoms can be present. See "Component Detect Atom" for more
  # information.
  # 
  # Quality atom
  # A reference movie atom may contain an optional quality atom. Only one quality atom
  # can be present. See "Quality Atom" for more information

  class QTRefMovieDescriptor < QTBase
    def initialize
      super
      @type = 'rmda'
    end
    
    #def set_data_reference( qt_data_reference )
    #  add_chunk qt_data_reference, 0
    #end
    
    #def set_data_rate( qt_data_rate )
    #  add_chunk qt_data_rate, 1
    #end
  end


  # Data Reference Atom
  # A data reference atom contains the information necessary to locate a movie, or a
  # stream or file that QuickTime can play, typically in the form of a URL or a file
  # alias.
  # 
  # Only one data reference atom is allowed in a given movie reference descriptor atom.
  # 
  # 
  # 
  # A data reference atom may contain the following information.
  # 
  # Size
  # The number of bytes in this data reference atom.
  # 
  # Type
  # The type of this atom; this field must be set to 'rdrf'.
  # 
  # Flags
  # A 32-bit integer containing flags. One flag is currently defined: movie is
  # self-contained. If the least-significant bit is set to 1, the movie is self-contained.
  # This requires that the parent movie contain a movie header atom as well as a reference
  # movie atom. In other words, the current 'moov' atom must contain both a 'rmra' atom
  # and a 'mvhd' atom. To resolve this data reference, an application uses the movie
  # defined in the movie header atom, ignoring the remainder of the fields in this data
  # reference atom, which are used only to specify external movies.
  # 
  # Data reference type
  # The data reference type. A value of 'alis' indicates a file system alias record. A
  # value of 'url ' indicates a string containing a uniform resource locator. Note that
  # the fourth character in 'url ' is an ASCII blank (hex 20).
  # 
  # Data reference size
  # The size of the data reference in bytes, expressed as a 32-bit integer.
  # 
  # Data reference
  # A data reference to a QuickTime movie, or to a stream or file that QuickTime can play.
  # If the reference type is 'alis' this field contains the contents of an AliasHandle.
  # If the reference type is 'url ' this field contains a null-terminated string that can
  # be interpreted as a URL. The URL can be absolute or relative, and can specify any
  # protocol that QuickTime supports, including http://, ftp://, rtsp://, file:///, and
  # data:.

  class QTDataReference < QTBase
    def initialize( reference = nil )
      super()
      @type = 'rdrf'
      @flag = 0
      @ref_type = 'url '
      @size = 0
      @reference = ''
      set_reference(reference) unless reference.nil?
    end
    
    def set_reference( reference )
      @reference = reference
      @size = reference.length
    end
    
    def size
      @size + 5 * 4
    end
    
    def to_s
      str =  [size].pack('N')
      str += @type
      str += [@flag].pack('N')
      str += @ref_type
      str += [@size].pack('N')
      str += @reference
    end
  end


  # Data Rate Atom
  # A data rate atom specifies the minimum data rate required to play a movie. This is
  # normally compared to the connection speed setting in the user's QuickTime Settings
  # control panel. Applications should play the movie with the highest data rate less
  # than or equal to the user's connection speed. If the connection speed is slower than
  # any movie's data rate, applications should play the movie with the lowest data rate.
  # The movie with the highest data rate is assumed to have the highest quality.
  # 
  # Only one data rate atom is allowed in a given reference movie descriptor atom.
  # 
  # A data rate atom may contain the following information.
  # 
  # Size
  # The number of bytes in this data rate atom.
  # 
  # Type
  # The type of this atom; this field must be set to 'rmdr'.
  # 
  # Flags
  # A 32-bit integer that is currently always 0.
  # 
  # Data rate
  # The required data rate in bits per second, expressed as a 32-bit integer.

  class QTDataRate < QTBase
    def initialize( rate = nil )
      super()
      @type = 'rmdr'
      @flag = 0
      @rate = 256000
      set_rate(rate) unless rate.nil?
    end
    
    def rates
      { '28.8 modem'  => 28800,
        '56k modem'   => 56000,
        'isdn'        => 64000,
        'dual isdn'   => 128000,
        '256 kbps'    => 256000,
        '384 kbps'    => 384000,
        '512 kbps'    => 512000,
        '768 kbps'    => 768000,
        '1 mbps'      => 1000000,
        't1'          => 1500000,
        'intranet'    => 2147483647 }
    end
    
    def set_rate( rate )
      @rate = rates[rate] || rate
    end
    
    def size
      4 * 4
    end
    
    def to_s
      str =  [size].pack('N')
      str += @type
      str += [@flag].pack('N')
      str += [@rate].pack('N')
    end

  end


  # CPU Speed Atom
  # A CPU speed atom specifies the minimum computing power needed to display a movie.
  # QuickTime performs an internal test to determine the speed of the user's computer.
  # 
  # This is not a simple measurement of clock speed-it is a measurement of performance
  # for QuickTime-related operations. Speed is expressed as a relative value between 100
  # and 2^31, in multiples of 100.
  # 
  # Note: Typical scores might range from a minimum score of 100, which would describe a
  # computer as slow as, or slower than, a 166 MHz Pentium or 120 MHz PowerPC, to a
  # maximum score of 600 for a 500 MHz Pentium III or 400 MHz G4 PowerPC. A computer with
  # a graphics accelerator and a Gigahertz clock speed might score as high as 1000.
  # Future computers will score higher.
  # 
  # Applications should play the movie with the highest specified CPU speed that is less
  # than or equal to the user's speed. If the user's speed is lower than any movie's CPU
  # speed, applications should play the movie with the lowest CPU speed requirement. The
  # movie with the highest CPU speed is assumed to be the highest quality.
  # 
  # Only one CPU speed atom is allowed in a given reference movie descriptor atom.
  # 
  # 
  # A CPU speed atom may contain the following information.
  # 
  # Size
  # The number of bytes in this CPU speed atom.
  # 
  # Type
  # The type of this atom; this field must be set to 'rmcs'.
  # 
  # Flags
  # A 32-bit integer that is currently always 0.
  # 
  # CPU speed
  # A relative ranking of required computer speed, expressed as a 32-bit integer
  # divisible by 100, with larger numbers indicating higher speed.

  class QTCPUSpeed < QTBase
    def initialize( speed = nil )
      super()
      @type = 'rmcs'
      @flag = 0
      @speed = 500
      set_speed(speed) unless speed.nil?
    end
    
    def speeds
      { 'very slow' => 100,
        'slow'      => 300,
        'medium'    => 500,
        'fast'      => 700,
        'very fast' => 1000 }
    end
    
    def set_speed( speed )
      @speed = speeds[speed] || speed
    end
    
    def size
      4 * 4
    end
    
    def to_s
      str =  [size].pack('N')
      str += @type
      str += [@flag].pack('N')
      str += [@speed].pack('N')
    end
  end


  # Quality Atom
  # A quality atom describes the relative quality of a movie. This acts as a tie-breaker
  # if more than one movie meets the specified requirements, and it is not otherwise
  # obvious which movie should be played.
  # This would be the case if two qualified movies have the same data rate and CPU speed
  # requirements, for example, or if one movie requires a higher data rate and another
  # requires a higher CPU speed, but both can be played on the current system. In these
  # cases, applications should play the movie with the highest quality, as specified in
  # the quality atom.
  # Only one quality atom is allowed in a given reference movie descriptor atom.
  # 
  # A quality atom may contain the following information.
  # 
  # Size
  # The number of bytes in this quality atom.
  # 
  # Type
  # The type of this atom; this field must be set to 'rmqu'.
  # 
  # Quality
  # The relative quality of the movie, expressed as a 32-bit integer. A larger number indicates higher quality. A unique value should be given to each movie.

  class QTQuality < QTBase
    def initialize( quality = nil )
      super()
      @type = 'rmqu'
      @flag = 0
      @quality = 500
      set_quality(quality) if quality
    end
    
    def set_quality( quality )
      @quality = quality
    end
    
    def size
      4 * 4
    end
    
    def to_s
      str =  [size].pack('N')
      str += @type
      str += [@flag].pack('N')
      str += [@quality].pack('N')
    end
  end

end
