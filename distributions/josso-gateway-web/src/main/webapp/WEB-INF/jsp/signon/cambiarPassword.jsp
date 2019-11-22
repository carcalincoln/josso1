<%@ page language="java" errorPage="/Error.jsp" import="admApli.*"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<html>
<head>
	<html:javascript formName="ModificarDatosUsuario"  />
	<title>Formulario de cambio de password</title>
</head>
<body>
	<bean:define id="persona" name="<%=Constantes.ClaveUsuario%>" property="persona" />
	<div id="formulario">
		<div class="titulo">
			Formulario de cambio de password
		</div>
	<html:form action="/signon/cambiarPassword.do"  onsubmit="return validateModificarDatosUsuario(this);" >
		
	<table class="formulario">
		<tr>
			<td colspan="3">
				<div class="tituloSeccion">
					Datos personales:
				</div>
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				Nombre
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<bean:write name="persona" property="nombre" />
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				Apellido
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>			
			<td class="campoFormulario">
				<bean:write name="persona" property="apellido" />
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				CUIT/CUIL
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<bean:write	name="persona" property="cuit_cuil" />
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				Dirección
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<bean:write	name="persona" property="direccion" />
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				CP/CPA
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<bean:write	name="persona" property="codigo_postal" />
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				Teléfono
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<bean:write	name="persona" property="telefono" />
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<div class="tituloSeccion">
					Password:
				</div>
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				Contraseña Actual
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<input type="password" name="password" maxlength="30">
				<span class="obligatorio">*</span>
			</td>
		</tr>
		<tr>
			<td class="nombreFormulario">
				Contraseña Nueva
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<input name="passwordNueva" maxlength="10" type="password">
				<span class="obligatorio">*</span>
			</td>	
		</tr>
		<tr>
			<td class="nombreFormulario">
				Repita Contraseña Nueva
			</td>
			<td class="separadorCampoFormulario">
				:
			</td>
			<td class="campoFormulario">
				<input type="password" name="password2Nueva" maxlength="10">
				<span class="obligatorio">*</span>
			</td>
		</tr>
		</table>
		<div id="botonera">
			<input name="enviar" type="submit" value="Enviar" size="20" />
			<input name="Borrar" type="reset"  value="Borrar" size="20"/>
		</div>
	</html:form>
	</div>
</body>