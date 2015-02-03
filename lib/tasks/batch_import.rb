#
# Ruby process for batch ingest, called by import_batches rake task
#

def import_batch
  manifest_filename = "manifest.yml"
  ingest_dir = "spec/fixtures/ingest/pmp"
  batch_folders = Dir.glob(ingest_dir + "/*").select { |f| File.directory? f }
  batch_folders.each_with_index do |subdir, index|
    puts "Processing batch directory #{index + 1} of #{batch_folders.size}: #{subdir}"
    begin
      manifest = YAML.load_file(subdir + "/" + manifest_filename)
    rescue
      puts "ABORTING: No manifest file found."
      manifest = nil
    end
    import_manifest(subdir, manifest) unless manifest.nil?
  end
end

def import_manifest(subdir, manifest)
  puts "Manifest file found."
  if manifest["pageds"].nil? or manifest["pageds"].empty?
    puts "ABORTING: No paged documents listed in manifest."
  else
    manifest["pageds"].each do |paged|
      import_paged(subdir, paged)
    end
  end
end

def import_paged(subdir, paged_yaml)
  paged_attributes = {}
  begin
    paged_yaml["descMetadata"].each_pair do |key, value|
      paged_attributes[key.to_sym] = value
    end
  rescue
    puts "ABORTING PAGED CREATION: invalid structure in descMetadata"
    return
  end
  if paged_attributes.any?
    begin
      paged = Paged.new(paged_attributes)
    rescue
      puts "ABORTING PAGED CREATION: invalid contents of descMetadata:"
      puts paged_attributes.inspect
      return
    end
  end
  if paged_yaml["content"] && paged_yaml["content"]["pagedXML"]
    begin
      xmlPath = Rails.root + subdir + "content/" + paged_yaml["content"]["pagedXML"]
      puts "Adding pagedXML file."
      paged.pagedXML.content = File.open(xmlPath)
    rescue
      puts "ABORTING PAGED CREATION: unable to open specified XML file: #{xmlPath}"
      return
    end
  else
    puts "No pagedXML file specified."
  end
  if paged
    #TODO: check for failed connection
    if paged.save
      puts "Paged object successfully created."
    else
      puts "ABORTING PAGED CREATION: problem saving paged object"
      puts paged.errors.messages
      return
    end

    pages_yaml = paged_yaml["pages"]
    if pages_yaml.nil? or pages_yaml.empty?
      puts "No pages specified for page object."
    else
      #TODO: check page count exists?
      page_count = pages_yaml["page count"].to_i
      puts "Processing #{page_count.to_s} pages."
      #TODO: check page count matches pages provided?
      pages = []
      prev_page = nil
      print "Creating page records:"
      (0...page_count).each do |index|
        page_attributes = { paged_id: paged.pid, skip_sibling_validation: true }
        page_attributes[:prev_page] = prev_page.pid if prev_page
        pages_yaml["descMetadata"].each_pair do |key, values|
          page_attributes[key.to_sym] = values[index]
        end
        begin
	  page = Page.new(page_attributes)
        rescue
          puts "ABORTING: invalid page attributes:"
          puts page_attributes.inspect
          break
        end
        pageImage = pages_yaml["content"]["pageImage"][index] if pages_yaml["content"]
	page.pageImage.content = File.open(Rails.root + subdir + "content/" + pageImage) if pageImage
	if page.save(unchecked: true)
	  page.reload
	  pages << page
          unless prev_page.nil?
            prev_page.next_page = page.pid
            unless prev_page.save(unchecked: true)
              puts "ABORT: problems re-saving prior page"
              puts prev_page.errors.messages
              pages = []
              break
            end
          end
          prev_page = page
	  print "."
	else
	  puts "ABORT: problems saving page"
	  puts page.errors.messages
	  #TODO: destroy pages, paged?
	  pages = []
	  break
	end
      end
      puts "\nUpdating paged index."
      paged.reload
      paged.update_index
      puts "Done.\n"
    end
  end
end
