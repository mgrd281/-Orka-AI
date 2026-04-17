import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    var body: some View {
        ZStack {
            Color.orkaBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.orkaText)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text("O")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.white)
                    )
                    .padding(.bottom, 28)
                
                // Title
                Text("Orka AI")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.8)
                    .foregroundColor(.orkaText)
                
                Text("Koordinierte Intelligenz")
                    .font(.system(size: 14))
                    .foregroundColor(.orkaText3)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                
                // Form
                VStack(spacing: 10) {
                    if authVM.showRegister {
                        AuthField(text: $name, placeholder: "Dein Name", icon: "person")
                    }
                    
                    AuthField(text: $email, placeholder: "E-Mail-Adresse", icon: "envelope", keyboardType: .emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    AuthField(text: $password, placeholder: authVM.showRegister ? "Passwort (mind. 6 Zeichen)" : "Passwort", icon: "lock", isSecure: true)
                }
                .padding(.horizontal, 32)
                
                // Error
                if !authVM.errorMessage.isEmpty {
                    Text(authVM.errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.orkaRed)
                        .padding(.top, 10)
                        .transition(.opacity)
                }
                
                // Button
                Button(action: submit) {
                    Text(authVM.showRegister ? "Konto erstellen" : "Anmelden")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orkaText)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
                
                // Toggle
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        authVM.showRegister.toggle()
                        authVM.errorMessage = ""
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(authVM.showRegister ? "Bereits ein Konto?" : "Noch kein Konto?")
                            .foregroundColor(.orkaText2)
                        Text(authVM.showRegister ? "Anmelden" : "Registrieren")
                            .foregroundColor(.orkaAccent)
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 13))
                }
                .padding(.top, 24)
                
                Spacer()
            }
        }
    }
    
    private func submit() {
        if authVM.showRegister {
            authVM.register(name: name, email: email, password: password)
        } else {
            authVM.login(email: email, password: password)
        }
    }
}

struct AuthField: View {
    @Binding var text: String
    let placeholder: String
    var icon: String = ""
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.orkaText3)
                    .frame(width: 20)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .font(.system(size: 15))
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color.orkaSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orkaBorder, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
