<%@page import="admApli.exceptions.*"%>
<%@page import="rpba.PrintStackTrace"%>
<%@ page language="java" import="admApli.*,admApli.modelo.*,admApli.modelo.perfil.*,admApli.dao.*,java.util.*,java.io.*" errorPage=""%>
<%
	Ambiente ambiente=(Ambiente)request.getAttribute(Constantes.ClaveAmbiente);
	if (!new admApli.modelo.Intranet().controlar(ambiente)){
		response.sendRedirect((String)request.getAttribute("Host")+admApli.Configuracion.getString("DEFAULT_CONTEXT")+"/signon/login.do");
	}
%>

<%!
public ArrayList<Servicio> getServiciosAutirizado(admApli.dao.AdministradorServicio administradorServicio,JspWriter out) throws IOException  {
	ArrayList<Servicio> servicios=new ArrayList<Servicio>();
	/*id de los servicios de la aplicacion 4 Inhibiciones
	17 inhibición pev
	18 cesion pev
	19 pj
	20 procesadas
	25 permite modificar los datos de la cuenta de usuario*/
	try {
		servicios.add(administradorServicio.getServicio(17));
		servicios.add(administradorServicio.getServicio(18));
		servicios.add(administradorServicio.getServicio(19));
		servicios.add(administradorServicio.getServicio(20));
		servicios.add(administradorServicio.getServicio(25));
	} catch (RpbaSelectException e) {
		PrintStackTrace.printStackTrace(e);
	}
	return servicios;
}

public admApli.modelo.Autorizado crearAutorizado(Titular titular, String logon,String password, String email, Perfil perfil, Persona persona,JspWriter out) throws IOException,admApli.exceptions.RpbaExistenteException  {
	admApli.modelo.Autorizado autorizado = new admApli.modelo.Autorizado();
	autorizado.setTitular(titular);
	titular.addAutorizado(autorizado);
	autorizado.setPassword(password);
	autorizado.setLogon(logon);
	autorizado.setEmail(email);
	autorizado.setPerfil(perfil);
	autorizado.setPersona(persona);
	try{
		autorizado.persisti();
		autorizado.setEstadoUsuario(Habilitado.getInstance());
		autorizado.persisti();
	} catch (Exception e){
		PrintStackTrace.printStackTrace(e);
	}
	return autorizado;
}

public OrganismoOficialCC crearOrganismoConCosto(String cuio,String descripcion, PerfilExterno perfil, Cuit cuit,String direccion,JspWriter out)throws IOException  {
	try {
		OrganismoOficialCC organismo = new OrganismoOficialCC();
		organismo.setCuio(cuio);
		organismo.setDescripcion(descripcion);
		organismo.setPerfil(perfil);
		organismo.setCuit(cuit);
		organismo.setDireccion(direccion);
		AdministradorFactory.get(AdministradorOrganismo.Constante,
				AdministradorOrganismo.class).altaOrganismo(organismo);
		return organismo;
	} catch (RpbaInsertException e) {
		PrintStackTrace.printStackTrace(e);
	}
	return null;
}

private Interno crearInterno(Persona persona, String logon,	String password, PerfilInterno perfil, String email,Estructura estructura,JspWriter out) throws IOException {
	Interno interno = new Interno();

	interno.setPersona(persona);
	interno.setEstructura(estructura);
	interno.setPerfil(perfil);
	interno.setLogon(logon);
	interno.setPassword(password);
	interno.setEmail(email);
	try {
		interno.setEstadoUsuario(new Habilitado());
		interno.persisti();
		interno.setEstadoUsuario(Habilitado.getInstance());
		out.println("<br><b>"+logon+"</b> creado exitosamente");
		interno.persisti();
	} catch (LogonExistenteException e) {
		PrintStackTrace.printStackTrace(e);
	} catch (RpbaExistenteException e) {
		PrintStackTrace.printStackTrace(e);			
	} catch (RpbaInexistenteException e) {
		PrintStackTrace.printStackTrace(e);
	} catch (RpbaGeneralException e) {
		PrintStackTrace.printStackTrace(e);
	} catch (RpbaSqlException e) {
		PrintStackTrace.printStackTrace(e);
	}
	return interno;
}
private PerfilDatos crearPerfilDatosInterno(PerfilInterno perfilInterno,Estructura estructura,Interno creador,PerfilPorAplicacion perfilPorAplicacion,JspWriter out) throws IOException {
	PerfilDatos perfilDatos= new PerfilDatos();
	try {
		
		perfilDatos.setEstructura(estructura);
		perfilDatos.setFechaAlta(new Date());
		perfilDatos.setFechaUltAcceso(new Date());
		perfilDatos.setId_usuario(creador.getId());
		perfilDatos.setPerfilPorAplicacion(perfilPorAplicacion);
		perfilDatos.setUsuario(creador);
		perfilDatos.setPerfilInterno(perfilInterno);
	}
	catch(Exception e){
		PrintStackTrace.printStackTrace(e);
	}
	return perfilDatos;
}
%>

<%
try {
	//Produccion
	String usuarioPersona=request.getParameter("logon");
	AdministradorPerfiles administradorPerfiles = AdministradorFactory.get(AdministradorPerfiles.Constante,AdministradorPerfiles.class);

	//*****************Interno***************************/
	//Perfil Interno
	AdministradorUsuario administradorUsuario = AdministradorFactory.get(AdministradorUsuario.Constante,AdministradorUsuario.class);
	Interno creador= (Interno)administradorUsuario.getUsuario(1);
	Persona persona = creador.getPersona();
	AdministradorEstructuras administradorEstructura =AdministradorFactory.get(AdministradorEstructuras.Constante,AdministradorEstructuras.class);
	Estructura estructura=administradorEstructura.getEstructura( Long.valueOf(6));
	
	out.println("<br><br><br><b>Interno:</b>");
	
	PerfilInterno perfilO = new PerfilInterno();
	perfilO.setNombre("perfil:"+usuarioPersona);
	ArrayList<PerfilDatos> perfilesDatos= new ArrayList<PerfilDatos>();
	PerfilPorAplicacion perfilPorApli; 
	
	perfilPorApli=administradorPerfiles.getPerfilPorAplicacion(3);
	perfilesDatos.add(crearPerfilDatosInterno(perfilO,estructura,creador,perfilPorApli,out));
	
	perfilPorApli=administradorPerfiles.getPerfilPorAplicacion(4);
	perfilesDatos.add(crearPerfilDatosInterno(perfilO,estructura,creador,perfilPorApli,out));
	
	/*perfilPorApli=administradorPerfiles.getPerfilPorAplicacion(10);
	perfilesDatos.add(crearPerfilDatosInterno(perfilO,estructura,creador,perfilPorApli,out));*/
	
	perfilO.setPerfilesDatos(perfilesDatos);

	
//	perfilO.persisti();
	//out.println("<br>&emsp;Perfil Interno generado exitosamente");
	persona= new Persona();
	crearInterno(persona,usuarioPersona,"12",perfilO,usuarioPersona+"@mail",estructura,out);
	
}  catch (RpbaSelectException e) {
	PrintStackTrace.printStackTrace(e);
} catch (Exception e){
	PrintStackTrace.printStackTrace(e);
}

%>