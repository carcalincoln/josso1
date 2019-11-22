package admUsuario.forms;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.validator.GenericValidator;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.validator.ValidatorForm;

import comun.controles.Validaciones;

/**
 * Es usado en Cambiar Password (uso todos los campos menos email)
 * 
 */
public class ModificarDatosUsuario extends ValidatorForm {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public ModificarDatosUsuario() {
		super();

	}

	private String password;

	private String passwordNueva=null;

	private String password2Nueva=null;

	private String email;

	public String getPassword2Nueva() {
		return password2Nueva;
	}

	public void setPassword2Nueva(String password2Nueva) {
		this.password2Nueva = password2Nueva;
	}

	public String getPasswordNueva() {
		return passwordNueva;
	}

	public void setPasswordNueva(String passwordNueva) {
		this.passwordNueva = passwordNueva;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public ActionErrors validate(ActionMapping actionMapping,
			HttpServletRequest httpServletRequest) {

		ActionErrors errors = super.validate(actionMapping, httpServletRequest);
		if (errors.isEmpty()) {
			if(!GenericValidator.isBlankOrNull(passwordNueva)){
				//quiere cambiar la contraseña
				if(password.equals(passwordNueva)){
					// la contraseña que ingreso es igual a la anterior
					errors.add("passwordIguales",new ActionMessage("errors.passwordIguales"));
				}
				else{
					if(passwordNueva.equals(password2Nueva)){
						if(!Validaciones.validarPassword(passwordNueva)){
							//la contraseña nueva no cumple las condiciones de seguridad
							errors.add("",new ActionMessage("errors.pwdInvalidas",admApli.Configuracion.getString("longitudPassword")));
						}
					}	
					else{
						//no repitio bien la contraseña
						errors.add("passwordDistintas",new ActionMessage("errors.passwordDistintas"));
					}
				}
			}
		}
		return errors;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Override
	public void reset(ActionMapping arg0, HttpServletRequest arg1) {

		super.reset(arg0, arg1);
		this.email = "";
		this.password = "";
		this.password2Nueva = null;
		this.passwordNueva = null;
	}
	public boolean cambioPassword(){
		return !GenericValidator.isBlankOrNull(passwordNueva);
	}
}