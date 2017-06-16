module Hyrax
  # A replacement for Hydra::Derivatives::IoDecorator for a local file, the whole point being to have
  # something to pass to Hydra::Works::AddFileToFileSet.  All it has to do is respond
  # to: #read, #original_name and #mime_type.
  class IoWrapper < File
    attr_writer :original_name, :mime_type

    def original_name
      @original_name || self.class.basename(path)
    end

    def mime_type
      @mime_type || Hydra::PCDM::GetMimeTypeForFile.call(@original_name || path)
    end

    # Note, cannot be == to a File object, because it would not be symmetric!
    def ==(other)
      return false unless other.is_a?(self.class) && File.identical?(self, other)
      original_name == other.original_name && mime_type == other.mime_type
    end
  end
end
