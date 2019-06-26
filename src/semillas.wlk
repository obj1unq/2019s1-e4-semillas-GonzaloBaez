class Planta{
	var property anioDeObtencion
	var property altura
	
	method tolerancia(){return 0}
	method esFuerte(){
		return self.tolerancia()>10
	}
	method daNuevasSemillas(){return self.esFuerte()|| self.condicionEspecial()}
	method espacioOcupa(){return 0}
	method condicionEspecial(){return true}
	method esParcelaIdeal(parcela){return true}
	method seAsociaBien(parcela){
		parcela.esBienAsociable(self)
	}
}

class Menta inherits Planta{
	override method tolerancia(){return 6}
	override method condicionEspecial(){
		return altura>0.4
	}
	override method espacioOcupa(){
		return altura*3
	}
	override method esParcelaIdeal(parcela) {
		return parcela.superficie()>6
	}
}

class Soja inherits Planta{
	override method tolerancia(){
		return if(altura<0.5){return 6} else if(altura<1){return 7} else{9}
	}
	override method condicionEspecial(){
		return (anioDeObtencion.year()>2007 && altura>1)
	}
	override method espacioOcupa(){
		return altura/2
	}
	override method esParcelaIdeal(parcela){
		return (parcela.horasDeSol() == self.tolerancia())
	}
}

class Quinoa inherits Planta{
	var tolerancia
	override method tolerancia(){
		return tolerancia
	}
	override method espacioOcupa(){return 0.5}
	override method condicionEspecial(){
		return anioDeObtencion.year()<2005
	}
	override method esParcelaIdeal(parcela){
		return parcela.plantas().all{planta=>planta.altura()<1.5}
	}
}

class SojaTrans inherits Soja{
	override method daNuevasSemillas(){return false}
	override method esParcelaIdeal(parcela){
		return parcela.plantasMaximas() == 1
	}
}
class HierbaBuena inherits Menta{
	override method espacioOcupa(){
		return altura*3*2
	}
} 

class Parcela{
	var ancho
	var largo
	var property horasDeSol
	const property plantas = #{}
	
	method superficie(){return ancho * largo}
	method plantasMaximas(){
		return if(ancho>largo){self.superficie()/5} else {(self.superficie()/3)+largo}
	}
	method tieneComplicaciones(){
		return plantas.any{planta=>planta.tolerancia()<horasDeSol}
	}
	method cantDePlantas(){return if (plantas.isEmpty()){0}else {plantas.size()}}
	
	method plantar(planta){
		self.validarParcelaCompleta()
		self.validarPlantaNoAguanta(planta)
		plantas.add(planta)
	}
	method validarParcelaCompleta(){
		if(self.cantDePlantas() == self.plantasMaximas()){
			throw new UserException ("la parcela esta completa")
		}
	}
	method validarPlantaNoAguanta(planta){
		if((horasDeSol - planta.tolerancia() >= 2)){
			throw new UserException ("la planta no aguanta la exposicion del sol")
		}
	}
	method esBienAsociable(planta){
		return true
	}
	method cantDePlantasBienAsociadas(){
		return plantas.filter{planta=>self.esBienAsociable(planta)}.size()
	}
	method porcentajeDePlantasBienAsociadas(){
		return (self.cantDePlantasBienAsociadas() / self.cantDePlantas())
	}
}
class ParcelaEcologica inherits Parcela{
	override method esBienAsociable(planta){
		return (not self.tieneComplicaciones() && planta.esParcelaIdeal())
	}
}

class ParcelaIndustrial inherits Parcela{
	override method esBienAsociable(planta){
		return (self.cantDePlantas()<=2 && planta.esFuerte())
	}
}

object inta{
	const property parcelas = #{}
	
	method promedioDePlantas(){
		return if (self.noHayParcelas()){
						self.sumaTotalDePlantas() / self.cantDeParcelas()
						}else{0}
	}
	method noHayParcelas(){return parcelas.isEmpty()}
	method sumaTotalDePlantas(){
		return parcelas.sum{parcela=>parcela.cantDePlantas()}
	}
	method cantDeParcelas(){
		return parcelas.size()
	}
	method parcelasConMasDe4Plantas(){
		return parcelas.filter{parcela=>parcela.cantPlantas()>4}
	}
	method parcelaMasAutosustentable(){
		return self.parcelasConMasDe4Plantas().max{parcela => parcela.porcentajeDePlantasBienAsociadas()}
	}
}

class UserException inherits Exception { }

