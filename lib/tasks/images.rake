namespace :images do
  desc "Make the dithered stand-ins (Dither) for photos that have none (needs the R2 keys in .env)"
  task dither: :environment do
    images = Image.where(dither: nil).includes(file_attachment: :blob).select { |image| image.file.attached? }
    images.each.with_index(1) do |image, n|
      MakeDitherJob.perform_now(image)
      puts "#{n}/#{images.size} #{image.imageable_type} #{image.imageable_id}: #{image.alt}"
    rescue StandardError => error
      puts "#{n}/#{images.size} skipped #{image.alt}: #{error.message}"
    end
  end
end
