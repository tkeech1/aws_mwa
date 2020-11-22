import typer
from jinja2 import Template, Environment, FileSystemLoader

def run(api_endpoint: str = "", cognito_user_pool_id: str = "", cognito_user_pool_client_id: str = "", region: str = ""):

    template_path = './modules/s3deploy/jinja2_templates/templates'
    output_path = './modules/s3deploy/jinja2_templates/output/'
    templates = ['index.html.tmpl','confirm.html.tmpl','register.html.tmpl']

    loader = FileSystemLoader(template_path)
    env = Environment(loader=loader, variable_start_string='@@=', variable_end_string='=@@')

    for template_file_name in templates:

        template = env.get_template(template_file_name)
        final_file_name = template_file_name[0:template_file_name.rindex('.')]
        output_from_parsed_template = template.render(api_endpoint=api_endpoint,cognito_user_pool_id=cognito_user_pool_id,cognito_user_pool_client_id=cognito_user_pool_client_id,region=region)

        with open(output_path + final_file_name, "w") as fh:
            fh.write(output_from_parsed_template)

if __name__ == "__main__":
    typer.run(run)