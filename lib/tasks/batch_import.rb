#
# Ruby process for batch process and ingest, called by rake tasks
#

module PMP

  module Ingest

    module Tasks

      def Tasks.process_batches
        Helpers::ingest_folders.each_with_index do |subdir, index|
          print "Processing batch directory #{index + 1} of #{Helpers::ingest_folders.size}: #{subdir}\n"
          xlsx_files = Dir.glob(subdir + "/" + "manifest*.xlsx").select { |f| File.file?(f) }
          if xlsx_files.any?
            xlsx_files.each do |manifest_filename|
              begin
                manifest = Roo::Excelx.new(manifest_filename)
              rescue
                puts "ABORTING: Unable to open/parse manifest file: #{manifest_filename}"
                manifest = nil
              end
              Helpers::convert_manifest(subdir, manifest) unless manifest.nil?
            end
          else
            print "No package files found to process.\n"
          end
        end
      end

      def Tasks.ingest_batches
        Helpers::ingest_folders.each_with_index do |subdir, index|
          print "Ingesting batch directory #{index + 1} of #{Helpers::ingest_folders.size}: #{subdir}\n"
          manifest_files = Dir.glob(subdir + "/" + "manifest*.yml").select { |f| File.file?(f) }
          if manifest_files.any?
            manifest_files.each do |manifest_filename|
              begin
                manifest = YAML.load_file(manifest_filename)
              rescue
                puts "ABORTING: Unable to open/parse manifest file: #{manifest_filename}."
                manifest = nil
              end
              print "Found manifest file: #{manifest_filename}\n"
              Helpers::import_manifest(subdir, manifest) unless manifest.nil?
            end
          else
            print "No manifest YAML files found in this directory.\n"
          end
        end
      end
    end
    module Helpers

      def Helpers.ingest_folders
        ingest_root = "spec/fixtures/ingest/pmp/"
        return Dir.glob(ingest_root + "*").select { |f| File.directory?(f) }
      end
      
      #FIXME: get actual id, date values
      def Helpers.manifest_hash(options = {})
        options['id'] ||= 'mybatch'
        options['date'] ||= '12-1-2014'
      
        { 'manifest' => { 'id' => options['id'], 'date' => options['date'] },
          'pageds' => options['pageds'] || []
        }
      end
      
      def Helpers.paged_hash(options = {}) 
        { 'descMetadata' => { 'title' => options['title'],
                              'creator' => options['creator'],
                              'type' => options['type'],
                              'publisher' => options['publisher'],
                              'publisher_place' => options['publisher_place'],
                              'paged_struct' => options['paged_struct'] || []
                            },
          'content' => { 'pagedXML' => options['pagedXML']},
          'pages' => options['pages'] || []
        }
      end
      
      def Helpers.page_hash(options = {})
        { 'descMetadata' => { 'logical_number' => options['logical_number'],
                              'text' => options['text'],
                              'page_struct' => options['page_struct'] || []
                            },
          'content' => { 'pageImage' => options['pageImage'],
                         'pageOCR' => options['pageOCR'],
                         'pageXML' => options['pageXML']
                       }
        }
      end
      
      def Helpers.structure_array(struct_string, delimiter = '--')
        result = struct_string.split(delimiter)
        result.each_with_index do |value, index|
          result[index] = result[index - 1] + delimiter + value unless index == 0
        end
        result
      end
      
      def Helpers.convert_manifest(subdir, manifest)
        # validate paged, abort otherwise
        # validate page, abort otherwise
        begin
          paged_sheet = manifest.sheet('Paged')
        rescue
          puts "ABORTING: Paged sheet not found."
        end
        if paged_sheet
          begin
            page_sheet = manifest.sheet('Page')
          rescue
            puts "ABORTING: Page sheet not found."
            #FIXME: abort
          end
          manifest.default_sheet = 'Paged'
          #FIXME: assign actual id, date values
          manifest_yaml = manifest_hash
          2.upto(paged_sheet.last_row).each do |n|
            hashed_row = Hash[(paged_sheet.row(1).zip(paged_sheet.row(n)))]
            hashed_row['paged_struct'] = structure_array(hashed_row['is_part_of'])
            hashed_row.delete('is_part_of')
            print "Parsing paged object: #{hashed_row['title']}\n"
            #for each batch id: parse page, pages data
            manifest_yaml['pageds'] << paged_hash(hashed_row)
            #ADD: paged_struct
            #PROCESS PAGES
            manifest.default_sheet = 'Page'
            print "Parsing pages:"
            2.upto(page_sheet.last_row).each do |page|
              hashed_page = Hash[(page_sheet.row(1).zip(page_sheet.row(page)))]
              hashed_page['page_struct'] = structure_array(hashed_page['is_part_of'])
              hashed_page.delete('is_part_of')
              if hashed_page['batch_id'] == hashed_row['batch_id']
                manifest_yaml['pageds'][-1]['pages'] << page_hash(hashed_page) if hashed_page['batch_id'] == hashed_row['batch_id']
                print "."
              end
            end
            print "#{manifest_yaml['pageds'][-1]['pages'].size} pages parsed.\n"
            manifest.default_sheet = 'Paged'
          end
          # FIXME: check before overwriting existing yml file?
          begin
            filename = subdir + "/" + "manifest.yml"
            File.open(filename, 'w') {|f| f.write manifest_yaml.to_yaml }
          rescue
            puts "ABORT: Problem saving manifest YAML file."
          end
        end
      end
      
      def Helpers.import_manifest(subdir, manifest)
        if manifest["pageds"].nil? or manifest["pageds"].empty?
          puts "ABORTING: No paged documents listed in manifest."
        else
          manifest["pageds"].each do |paged|
            print "Importing paged object: #{paged['descMetadata'] && paged['descMetadata']['title'] ? paged['descMetadata']['title'] : '(title unavailable)'}\n"
            import_paged(subdir, paged)
          end
        end
      end
      
      def Helpers.import_paged(subdir, paged_yaml)
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
            print "Adding pagedXML file.\n"
            paged.pagedXML.content = File.open(xmlPath)
          rescue
            puts "ABORTING PAGED CREATION: unable to open specified XML file: #{xmlPath}"
            return
          end
        else
          print "No pagedXML file specified.\n"
        end
        if paged
          #TODO: check for failed connection
          if paged.save
            print "Paged object #{paged.pid} successfully created.\n"
          else
            puts "ABORTING PAGED CREATION: problem saving paged object"
            puts paged.errors.messages
            return
          end
      
          pages_yaml = paged_yaml["pages"]
          if pages_yaml.nil? or pages_yaml.empty?
            print "No pages specified for page object.\n"
          else
            #TODO: check page count exists?
            page_count = pages_yaml.count
            print "Processing #{page_count.to_s} pages:"
            #TODO: check page count matches pages provided?
            pages = []
            prev_sib = nil
            (0...page_count).each do |index|
              page_attributes = { parent: paged.pid, skip_sibling_validation: true }
              page_attributes[:prev_sib] = prev_sib.pid if prev_sib
              pages_yaml[index]["descMetadata"].each_pair do |key, value|
                page_attributes[key.to_sym] = value
              end
              begin
                page = Page.new(page_attributes)
              rescue
                puts "ABORTING: invalid page attributes:"
                puts page_attributes.inspect
                break
              end
              if pages_yaml[index]["content"]
                pageImage = pages_yaml[index]["content"]["pageImage"]
                begin
                  page.image_file = File.open(Rails.root + subdir + "content/" + pageImage) if pageImage
                rescue
                  puts "ABORTING: Error opening image file: #{pageImage}"
                  break
                end
                pageOCR = pages_yaml[index]["content"]["pageOCR"]
                begin
                  page.ocr_file = File.open(Rails.root + subdir + "content/" + pageOCR) if pageOCR
                rescue
                  puts "ABORTING: Error opening OCR file: #{pageOCR}"
                  break
                end
                pageXML = pages_yaml[index]["content"]["pageXML"]
                begin
                  page.xml_file = File.open(Rails.root + subdir + "content/" + pageXML) if pageXML
                rescue
                  puts "ABORTING: Error opening XML file: #{pageXML}"
                  break
                end
              end
              if page.save(unchecked: true)
                page.reload
                pages << page
                unless prev_sib.nil?
                  prev_sib.next_sib = page.pid
                  unless prev_sib.save(unchecked: true)
                    puts "ABORT: problems re-saving prior page"
                    puts prev_sib.errors.messages
                    pages = []
                    break
                  end
                end
                prev_sib = page
                print "."
              else
                puts "ABORT: problems saving page"
                puts page.errors.messages
                #TODO: destroy pages, paged?
                pages = []
                break
              end
            end
            print "\nUpdating paged index.\n"
            paged.children = pages.map { |page| page.pid }
            paged.save(unchecked: true)
            paged.reload
            paged.update_index
            print "Done.\n\n"
          end
        end
      end
    end  
  end
end
