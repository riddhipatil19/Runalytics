package com.riddhi.runntrackerbackend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

@Data
@Schema(description = "Request body for user signup")
public class SignupRequestDTO {

    @NotEmpty
    @Schema(example = "Riddhi", description = "User's full name")
    private String name;

    @NotEmpty
    @Schema(example = "riddhi@email.com", description = "User email")
    private String email;

    @NotEmpty
    @Schema(example = "password123", description = "User password")
    private String password;
}
