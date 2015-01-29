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
  end
  if paged_attributes.any?
    begin
      paged = Paged.new(**paged_attributes)
    rescue
      puts "ABORTING PAGED CREATION: invalid contents of descMetadata"
    end
  end
  if paged_yaml["content"] && paged_yaml["content"]["pagedXML"]
    begin
      xmlPath = Rails.root + subdir + "content/" + paged_yaml["content"]["pagedXML"]
      puts "Adding pagedXML file."
      test_file = File.open(xmlPath)
      #test_file = File.open(Rails.root + subdir + "content/" + paged_yaml["content"]["pagedXML"])
      paged.pagedXML.content = test_file
    rescue
      puts "ABORTING PAGED CREATION: unable to open specified XML file: #{xmlPath}"
      paged = nil
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
      print "Creating initial page records"
      (0...page_count).each do |index|
	page = Page.new(paged: paged, logical_number: pages_yaml["descMetadata"]["logical_num"][index])
	page.pageImage.content = File.open(Rails.root + subdir + "content/" + pages_yaml["content"]["pageImage"][index]) unless pages_yaml["content"]["pageImage"][index].to_s.blank?
	if page.save(unchecked: true)
	  page.reload
	  pages << page
	  print "."
	else
	  puts "ABORT: problems saving page"
	  puts page.errors.messages
	  #TODO: destroy pages, paged?
	  pages = []
	  break
	end
      end
      print "\nSetting page relationships"
      pages.each_with_index do |page, index|
        pages[index].prev_page = pages[index - 1].pid unless index.zero?
	pages[index].next_page = pages[index + 1].pid unless index >= (pages.size - 1)
	if page.save(unchecked: true)
	  print "."
	else
	  puts "ABORT: problems saving page"
	  puts page.errors.messages
	  #TODO: destroy pages, paged?
	  pages = []
	  break
	end
      end
      print "\nUpdating paged index."
      paged.reload
      paged.update_index
      print "\nDone.\n\n"
    end
  end
end
