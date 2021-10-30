module Rute
    def polycon_exist?(method)
        if Dir.exists?(Dir.home+"/.polycon")
            method.call
        else
            warn "Se va a crear el directorio polycon, vuelva a ejecutar la operación que desea realizar"
            Dir.mkdir(Dir.home+"/.polycon")
        end
    end
    
    def professional_rute (professional)
        Dir.home+"/.polycon/#{professional.gsub(" ", "_")}"
    end

    def professional_exist?(professional)
        Dir.exists?(self.professional_rute(professional))
    end

    def appointment_rute (date, professional)
        self.professional_rute(professional)+"/#{date.gsub(" ", "_")}.paf"
    end

    def appointment_exist?(date, professional)
        File.exists?(self.appointment_rute(date, professional))
    end
end