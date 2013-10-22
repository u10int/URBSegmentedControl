Pod::Spec.new do |s|
	s.name				= 'URBSegmentedControl'
	s.version			= '1.0.0'
	s.summary			= 'A replacement for UIKit\'s UISegmentedControl that offers a greater level of flexibility and customization.'
	s.description		= ''
	s.homepage			= 'https://github.com/u10int/URBSegmentedControl'
	s.author = {
		'Nicholas Shipes' => 'nshipes@urban10.com'
	}
	s.source = {
		:git	=> 'https://github.com/u10int/URBSegmentedControl.git',
		:tag	=> '1.0.0'
	}
	s.platform			= :ios, 5.0
	s.license			= 'MIT'
	s.requires_arc		= true
	s.source_files		= '*.{h,m}'
	s.frameworks		= 'CoreGraphics, QuartzCore'
end