require 'fileutils'
require "json"
require 'yaml'

# module for generating a photo gallery
module GalleryTag
	def self.getTagImageInfo(photo_dir, tag_name)
		tagGalleryData = YAML.load_file(photo_dir + "/" + tag_name+'/result.yml' )
		array_of_images = tagGalleryData['images']
		#sort the data by year-month
		array_of_images.sort_by! { |image| [-image ['year'].to_i, -image['month'].to_i ]  }
		tagGalleryData['images'] = array_of_images
		return tagGalleryData
	end

	# Generates a photo gallery with a home page with all possible 'tags'
	# that each link to a separate page with all the tags images
	class GalleryTagGenerator < Jekyll::Generator
		safe true

		def generate(site)

			config = site.config["gallerytags"]
			photo_dir = config["dir"]
			tags = config["galleries"]

			cover_info = {}
			tags.each{ |tag|
				galleryInformation = GalleryTag::getTagImageInfo(photo_dir, tag)
				cover_info[tag] = {'gallery_thumbnail'=>galleryInformation['cover'],'gallery_title'=>galleryInformation['name']}
				site.pages << GalleryPage.new(site, photo_dir, tag, galleryInformation)
			}
			site.pages << GalleryHomePage.new(site, photo_dir,tags, cover_info)
		end
	end

	# home page that lists all tag pages
	class GalleryHomePage < Jekyll::Page
		def initialize(site, photo_dir, tag_list, cover_info)
			@site = site
			@base = site.source
			@dir  = photo_dir          

			@basename = 'index'
			@ext      = '.html'   
			@name     = 'home.html'

			@tags = tag_list
			@cover_info = cover_info

			self.content = File.read( File.join(@base.to_s, "_plugins/home.html") )

			self.data = {
				'layout' => 'default',
				'title' => "Photos",
				'photo_dir' => photo_dir,
				'tags' => @tags,
				'cover_info' => @cover_info
			}
			end
	end

	# a single tag page
	class GalleryPage < Jekyll::Page

	def initialize(site, photo_dir, tag_name, galleryInformation)

		@site = site            
		@base = site.source    
		@dir  = photo_dir+'/'+tag_name
		@basename = 'index'      
		@ext      = '.html'   
		@name     = 'tag.html' 

		@image_blocks = []
		@thumbnail_blocks = []
		@date_block = []

		@images = []
		@thumbnails = []

		@exclude = true

		image_data = galleryInformation['images']
		summary = galleryInformation['summary']
		gallery_name = galleryInformation['name']

		current_date = ''
		last_date = ''
		current_block = []
		image_data.each{ |item|

		last_date = (item['year']+'-'+item['month'])

		if(current_date === '')
			current_date = last_date
			@date_block.push(current_date)
		end

		if( not ( last_date === current_date ) )
			@image_blocks.push(current_block)
			@date_block.push(current_date)
			current_date = last_date
			current_block = []
			end
			current_block.push({"image"=>item['name'],"thumbnail"=>item['thumbnail'], "caption" => item['caption']})
		}
		@image_blocks.push(current_block)
		@date_block.push(current_date)

		self.content = File.read( File.join(@base.to_s, "_plugins/tag.html") )
		self.data = {
			'layout' => 'default',
			'title' => gallery_name,
			'image_blocks' => @image_blocks,
			'date_block' => @date_block,
			'site_summary' => summary,
			'exclude' => @exclude
		}
		end
	end
end
