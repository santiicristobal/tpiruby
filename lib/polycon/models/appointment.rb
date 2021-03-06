require "./lib/polycon/models/path"
require "date"
require "erb"
require "./lib/polycon/models/professional"
class Appointment include Rute
    def date_control(date)
        begin
            DateTime.parse(date).strftime("%F_%R")
        rescue
            warn "La fecha debe tener el formato AAAA-MM-DD_HH-II"
        end
    end

    def initialize(date, professional)
        @date= self.date_control(date)
        @professional= professional
    end

    def professional
        @professional
    end

    def date
        @date
    end

    def create (name, surname, phone, notes)
        create=Proc.new do
        if (self.professional_exist?(@professional))
            if (self.appointment_exist?(@date, @professional))
                warn "Ese horario ya no se encuentra disponible"
            else
                a= File.open((self.appointment_rute(@date, @professional)), "w")
                a.puts("#{name}\n#{surname}\n#{phone}\n#{notes}")
                a.close
            end
        else
            warn "No existe ese profesional"
        end
        end
        self.polycon_exist?(create)
    end

    def self.reschedule (old_date, new_date, professional) 
        extend Rute
        begin
        od= DateTime.parse(old_date).strftime("%F_%R")
        nd= DateTime.parse(new_date).strftime("%F_%R")
        reschedule=Proc.new do
        if (self.appointment_exist?(od, professional))
            File.rename(self.appointment_rute(od, professional),self.appointment_rute(nd, professional))
        else
            warn "No se puede renombrar porque ese turno para ese profesional no existe"
        end
        end
        self.polycon_exist?(reschedule)
        rescue
            warn "Formato de fecha incorrecto"
        end
    end

    def cancel
    cancel=Proc.new do
    if (self.appointment_exist?(@date, @professional))
        File.delete(self.appointment_rute(@date, @professional))
    else
        warn "No se puede cancelar el turno ingresado porque no existe"
    end
    end
    self.polycon_exist?(cancel)
    end

    def self.cancelAll (professional)
    extend Rute
    ca= Proc.new do
    if (self.professional_exist?(professional))
        FileUtils.rm_rf(Dir.glob("#{self.professional_rute(professional)}/*"))
    else
        warn "No existe ese profesional"
    end
    end
    self.polycon_exist?(ca)
    end

    def self.list (professional)
        extend Rute
        list=Proc.new do
        if (self.professional_exist?(professional))
            warn Dir.foreach(self.professional_rute(professional)).select {|p| !File.directory? p}
        else
            warn "No existe ese profesional"
        end
        end
        self.polycon_exist?(list)
    end

    def show
        show=Proc.new do
        if (self.professional_exist?(@professional))
            if (self.appointment_exist?(@date, @professional))
                warn File.read(self.appointment_rute(@date, @professional))
            else
                warn "No existe el turno"
            end
        else
            warn "No existe ese profesional" 
        end
        end
        self.polycon_exist?(show)
    end

    def edit(**options)
        edit=Proc.new do
        if (self.professional_exist?(@professional))
            if (self.appointment_exist?(@date, @professional))
                data= File.readlines(self.appointment_rute(@date, @professional))
                options.each do |k, v|
                    case k.to_s
                        when "name"
                            data[0]= "#{v}"
                        when "surname"
                            data[1]= "#{v}"
                        when "phone"
                            data[2]= "#{v}"
                        when "notes"
                            data[3]= "#{v}"
                    end
                end
                aux= File.open((self.appointment_rute(@date, @professional)), "w")
                aux.puts(data)
                aux.close
            else
                warn "No existe el turno"
            end
        else
            warn "No existe ese profesional"
        end
        end
        self.polycon_exist?(edit)
    end

    def self.htmlday(date, professional)
        appo=Appointment.appointmentDay(date, professional)
        template= <<-ERB
        <!DOCTYPE html>
        <html>
        <head>
            <title> Hola! </title>
        </head>
        <body>
            <h1 align="center"> <%=DateTime.parse(date).strftime("%F")%> </h1>
            <table align="center" border=1>
                <tr>
                    <th> Professional </th>
                    <th> hour </th>
                </tr>
                <% appointments.each do |appointment| %>
                    <tr>
                        <td> <%= appointment.professional.gsub("_", " ") %> </td>
                        <td> <%= DateTime.parse(appointment.date).strftime("%R") %> </td>
                    </tr>
                <% end %>
            </table>
        </body>
        </html>
        ERB
        erb= ERB.new(template)
        output= erb.result_with_hash(appointments:appo, date:date)
        File.write(Dir.home+"/grilladay.html", output)
    end

    def self.appointmentDay(date, professional)
        if (professional.nil?)
            arr2=[]
            arr=Professional.listWithoutWarn.to_a
            arr.each do |p|
                arr2=arr2+Appointment.appoDay(date, p)
            end
            arr2.to_a
        else
            arr=Appointment.appoDay(date, professional)
            arr.to_a
        end
    end

    def self.appoDay(date, professional)
        extend Rute
        l=Dir.foreach(self.professional_rute(professional)).select {|p| !File.directory? p}
        l.map {|p| 
        if (!File.directory? p) && (DateTime.parse(p).strftime("%F")==DateTime.parse(date).strftime("%F"))
            Appointment.new(p, professional)
        end
        }.compact
    end
end

