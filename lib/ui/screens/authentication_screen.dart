import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:chatpulse_ai/shaders/flowers_shader.dart';
import 'package:chatpulse_ai/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthenticationScreen extends StatelessWidget {
  AuthenticationScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SingleFlowerPainter(
        screenSize: MediaQuery.of(context).size,
      ),
      child: Scaffold(
          backgroundColor: const Color(0xFFd5d5e5).withOpacity(0.9),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2),
                        const AppText(
                          'ChatPulse AI',
                          fontSize: 32,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 64),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Colors.black54,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            hintText: 'Enter your email',
                            hintStyle: GoogleFonts.nunitoSans(
                              color: const Color.fromARGB(255, 42, 40, 40),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          cursorColor: Colors.black54,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            hintText: 'Enter your password',
                            hintStyle: GoogleFonts.nunitoSans(
                              color: const Color.fromARGB(255, 42, 40, 40),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: apiKeyController,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Colors.black54,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                            hintText: 'Enter your api key',
                            hintStyle: GoogleFonts.nunitoSans(
                              color: const Color.fromARGB(255, 42, 40, 40),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              context.read<ContentBloc>().add(
                                    ContentCreateUserEvent(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      apiKey: apiKeyController.text.trim(),
                                    ),
                                  );

                              FocusScope.of(context).unfocus();
                            },
                            child: const AppText(
                              'Login',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
