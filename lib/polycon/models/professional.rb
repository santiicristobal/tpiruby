require "./lib/polycon/models/path"
class Professional include Rute
    def create(professional)
        create=Proc.new do 
        if (self.professional_exist?(professional))
            warn "Si existe este profesional"
        else
            Dir.mkdir(self.professional_rute(professional))
        end
        end
        self.polycon_exist?(create)
    end

    def delete(professional)
        delete=Proc.new do
        if (self.professional_exist?(professional))
            Dir.delete(self.professional_rute(professional))
        else
            warn "No existe este profesional"
        end
        end
        self.polycon_exist?(delete)
    end

    def rename(old_name, new_name)
        rename=Proc.new do
        if (self.professional_exist?(old_name))
            File.rename(self.professional_rute(old_name),self.professional_rute(new_name))
        else
            warn "No existe este profesional"
        end
        end
        self.polycon_exist?(rename)
    end

    def list
        list=Proc.new do
        warn Dir.foreach((Dir.home) +"/.polycon").select {|p| !File.directory? p}
        end
        self.polycon_exist?(list)
    end
end