/*
 * JOSSO: Java Open Single Sign-On
 *
 * Copyright 2004-2009, Atricore, Inc.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 *
 */

package org.josso.selfservices.password.lostpassword;

import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.josso.auth.exceptions.AuthenticationFailureException;
import org.josso.auth.exceptions.MultipleUsersAuthenticationException;
import org.josso.gateway.SSOException;
import org.josso.gateway.identity.SSOUser;
import org.josso.gateway.identity.exceptions.MultipleUsersException;
import org.josso.gateway.identity.exceptions.SSOIdentityException;
import org.josso.selfservices.ChallengeResponseCredential;
import org.josso.selfservices.password.PasswordManagementProcess;

/**
 * @org.apache.xbean.XBean element="complexlostpassword-process"
 *
 * @author <a href="mailto:mleiro@rpba.gob.ar">Marcos Leiro</a>
 */
public class ComplexLostPasswordProcess extends AbstractLostPasswordProcess {

    private static final Log log = LogFactory.getLog(ComplexLostPasswordProcess.class);

    private String challengeId= "email";

    private String challengeText = "Email Address";
    
    private String challenge2Id= "logon";

    private String challenge2Text = "nombre de Usuario";    

    @Override
    public PasswordManagementProcess createNewProcess(String id) throws SSOException {
        ComplexLostPasswordProcess p = (ComplexLostPasswordProcess) super.createNewProcess(id);
        p.setChallengeId(challengeId);
        p.setChallengeText(challengeText);
        
        p.setChallenge2Id(challenge2Id);
        p.setChallenge2Text(challenge2Text);

        return p;
    }

    
     @Override
    protected ChallengeResponseCredential[] createAdditionalChallenges(Set<ChallengeResponseCredential> challenges) {
	 return null;
    }


    /**
     * This creates a single challenge using the value of the 'challengeId' and 'challengeText' properties.
     */
    protected ChallengeResponseCredential[] createInitilaChallenges() {

        ChallengeResponseCredential email = new ChallengeResponseCredential(challengeId, challengeText);
	ChallengeResponseCredential userName = new ChallengeResponseCredential(challenge2Id, challenge2Text);
	ChallengeResponseCredential[] aux=new ChallengeResponseCredential[] {userName,email};
        if (log.isDebugEnabled()) {
            log.debug("Create Initial Challenges ");
            for (int i = 0; i < aux.length; i++) {
		log.debug("id: "+aux[i].getId() + " value: "+aux[i].getValue());
	    }
        }
        return aux;
    }

    /**
     * This implementation authenticates a user using the response to the initial challenge created before.
     *
     * @throws AuthenticationFailureException if no challenge is received with the configured challengeId or a user
     *  cannot be authenticated whit the challenge response.
     */
    protected SSOUser authenticate(Set<ChallengeResponseCredential> challenges) throws AuthenticationFailureException {

        ChallengeResponseCredential challenge = getChallenge(challengeId, challenges);
        if (challenge == null)
            throw new AuthenticationFailureException("No challenge received : " + challengeId);
        
        ChallengeResponseCredential challenge2 = getChallenge(challenge2Id, challenges);
        if (challenge2 == null)
            throw new AuthenticationFailureException("No challenge received : " + challenge2Id);        

        try {
            ChallengeResponseCredential[] aux = new ChallengeResponseCredential[challenges.size()];
            aux= challenges.toArray(aux);
            String username = getIdentityManager().findUsernameByRelayCredential(aux);
            if (username == null)
                throw new AuthenticationFailureException("No user found for provided challenges");

            SSOUser user = findUserByUsername(username);
            if(log.isDebugEnabled()){
        	log.debug("User found for " + username);
            }

            return user;

        } catch (MultipleUsersException e) {
            throw new MultipleUsersAuthenticationException(e.getMessage());
        } catch (SSOIdentityException e) {
            log.error(e.getMessage(), e);
            throw new AuthenticationFailureException("No email received");
        }

    }

    // ------------------------------------------------------------------------------

    /**
     * @org.apache.xbean.Property alias="challeng-id"
     *
     * @return
     */
    public String getChallengeId() {
        return challengeId;
    }

    public void setChallengeId(String challengeId) {
        this.challengeId = challengeId;
    }

    /**
     * @org.apache.xbean.Property alias="challenge-text"
     * @return
     */
    public String getChallengeText() {
        return challengeText;
    }

    public void setChallengeText(String challengeText) {
        this.challengeText = challengeText;
    }
    /**
     * @org.apache.xbean.Property alias="challeng-id2"
     *
     * @return
     */
    public String getChallenge2Id() {
	return challenge2Id;
    }

    public void setChallenge2Id(String challenge2Id) {
	this.challenge2Id = challenge2Id;
    }
    /**
     * @org.apache.xbean.Property alias="challenge-text2"
     * @return
     */
    public String getChallenge2Text() {
	return challenge2Text;
    }

    public void setChallenge2Text(String challenge2Text) {
	this.challenge2Text = challenge2Text;
    }
}
