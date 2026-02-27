package Ecom.SecurityConfig;

import java.util.Arrays;
import java.util.Collections;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import jakarta.servlet.http.HttpServletRequest;

@Configuration
public class AppConfig {

    @Bean
    public SecurityFilterChain springSecurityConfiguration(HttpSecurity http) throws Exception {

        http
            // 1. Session management: stateless
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

            // 2. CORS configuration (simplified)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))

            // 3. CSRF disabled (for stateless APIs)
            .csrf(csrf -> csrf.disable())

            // 4. Add custom JWT filters
            .addFilterAfter(new JwtTokenGeneratorFilter(), BasicAuthenticationFilter.class)
            .addFilterBefore(new JwtTokenValidatorFilter(), BasicAuthenticationFilter.class)

            // 5. Authorization rules – order matters!
            .authorizeHttpRequests(auth -> auth
                // 🔓 Public endpoints (no authentication required)
                .requestMatchers("/actuator/health/**").permitAll()           // K8s probes
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/ecom/admin", "/ecom/customers").permitAll()
                .requestMatchers(HttpMethod.DELETE, "/ecom/orders/users/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/ecom/signIn", "/ecom/product-reviews/**", "/ecom/products/**").permitAll()

                // 👑 Role‑based endpoints – must come before .anyRequest()
                .requestMatchers(HttpMethod.POST, "/ecom/product/**", "/ecom/order-shippers/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.POST, "/ecom/product/**", "/ecom/product-reviews/**",
                                 "/ecom/customer-addresses/**", "/ecom/cart/**", "/ecom/orders/**",
                                 "/ecom/order-shipping/**").hasRole("USER")

                .requestMatchers(HttpMethod.PUT, "/ecom/admin/**", "/ecom/products/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT, "/ecom/admin/**", "/ecom/product-reviews/**",
                                 "/ecom/customer-addresses/update/**", "/ecom/cart/**",
                                 "/ecom/order-shipping/**").hasRole("USER")

                .requestMatchers(HttpMethod.DELETE, "/ecom/products/**", "/ecom/product-reviews/**",
                                 "/ecom/customer-addresses/delete/**", "/ecom/order-shipping/**",
                                 "/ecom/order-shippers/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/ecom/cart/remove-product/**").hasRole("USER")

                .requestMatchers(HttpMethod.GET, "/ecom/customer-addresses/**", "/ecom/cart/products/**",
                                 "/ecom/orders/**", "/ecom/order-shippers", "/ecom/order-payments/**")
                                 .hasAnyRole("ADMIN", "USER")

                // 🔐 All other requests must be authenticated
                .anyRequest().authenticated()
            )

            // 6. HTTP Basic (optional, can be removed if only JWT is used)
            .httpBasic(Customizer.withDefaults());

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList(
            "https://eccomers96.netlify.app",
            "http://localhost:3000"
        ));
        configuration.setAllowedMethods(Collections.singletonList("*"));
        configuration.setAllowedHeaders(Collections.singletonList("*"));
        configuration.setExposedHeaders(Arrays.asList("Authorization"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}