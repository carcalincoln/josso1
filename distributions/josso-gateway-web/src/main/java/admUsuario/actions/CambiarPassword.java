package admUsuario.actions;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import rpba.ActionRpba;
import admApli.Constantes;
import admApli.Errores;
import admApli.MD5;
import rpba.PrintStackTrace;
import admApli.modelo.Habilitado;
import admApli.modelo.Usuario;
import admApli.modelo.dtos.Error;

public class CambiarPassword extends ActionRpba {

	public CambiarPassword() {
		super();
	}

	public ActionForward executeRpba(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response) {
		admUsuario.forms.ModificarDatosUsuario formulario = (admUsuario.forms.ModificarDatosUsuario) form;
		Usuario usuario = getUsuario(request);
		try {
			if (usuario.getEstadoUsuario().equals(
					admApli.modelo.CambiarPassword.getInstance())) {

				usuario.setPassword(MD5
						.encriptar(formulario.getPasswordNueva()));
				usuario.setEstadoUsuario(Habilitado.getInstance());
				usuario.persisti();
			} else {
				Error error = new Error();
				error.setMensaje("Usted no esta autorizado para ingresar a esta pagina");
				error.setValorRetorno("Cerrar");
				error.setSubTitulo("Cambiar Password");
				error.setTitulo("Sin Permisos");
				error.setRetorno((String) request.getAttribute(Constantes.ClaveIndex));
				request.setAttribute(Constantes.ERROR, error);
				return mapping.findForward("mensaje");
			}
		} catch (Exception e) {
			PrintStackTrace.printStackTrace(e);
			Error error = new Error();
			error.setMensaje(Errores.getString("Error.mensaje"));
			error.setValorRetorno("Cerrar");
			error.setSubTitulo("Cambiar Password");
			error.setTitulo(Errores.getString("Error.titulo"));
			error.setRetorno((String) request
					.getAttribute(Constantes.ClaveIndex));
			request.setAttribute(Constantes.ERROR, error);
			return mapping.findForward("error");
		}
		return mapping.findForward("exito");
	}
}