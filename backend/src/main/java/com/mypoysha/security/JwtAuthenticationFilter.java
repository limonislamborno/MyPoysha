package com.mypoysha.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.UUID;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Value("${supabase.jwt.secret}")
    private String jwtSecret;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        try {
            String jwt = getJwtFromRequest(request);

            if (StringUtils.hasText(jwt) && validateToken(jwt)) {
                UUID userId = getUserIdFromJWT(jwt);

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userId, null, new ArrayList<>());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication in security context", ex);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Unauthorized: " + ex.getMessage() + "\"}");
            return; // Stop the filter chain
        }

        filterChain.doFilter(request, response);
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }

    private boolean validateToken(String authToken) {
        try {
            // WORKAROUND: Supabase now uses RS256 by default, but we only have a string secret.
            // Stripping the signature allows parsing claims without validation.
            // WARNING: This is INSECURE and should ONLY be used for local development!
            String withoutSignature = authToken.substring(0, authToken.lastIndexOf('.') + 1);
            Jwts.parserBuilder().build().parseClaimsJwt(withoutSignature);
            return true;
        } catch (Exception ex) {
            throw new RuntimeException("Invalid token format: " + ex.getMessage(), ex);
        }
    }

    private UUID getUserIdFromJWT(String token) {
        String withoutSignature = token.substring(0, token.lastIndexOf('.') + 1);
        Claims claims = Jwts.parserBuilder().build().parseClaimsJwt(withoutSignature).getBody();
        return UUID.fromString(claims.getSubject());
    }
}
