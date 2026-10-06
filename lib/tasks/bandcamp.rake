namespace :bandcamp do
  desc "Copy stock from Bandcamp onto the content (read only on Bandcamp's side)"
  task stock: :environment do
    puts BandcampStock.report
  end
end
