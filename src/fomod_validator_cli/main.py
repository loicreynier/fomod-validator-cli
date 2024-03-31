from pathlib import Path

import pyfomod
import typer
from typing_extensions import Annotated

app = typer.Typer(
    add_completion=False,
    rich_markup_mode="rich",
)


@app.command(
    help=(
        "[bold green]Validate[/bold green] "
        "FOMod installer in [underline]path[/underline]"
    ),
)
def validate(
    path: Annotated[
        Path,
        typer.Argument(
            help="Path of the folder containing the FOMod directory.",
            exists=True,
            dir_okay=True,
            file_okay=False,
            readable=True,
            resolve_path=True,
        ),
    ],
):
    """Validate FOMod installer in `path`."""
    validate_fomod(path)


def fomod_image_warnings(path: Path, instance):
    """Missing image warnings."""
    source = Path(path) / instance.image
    warnings = []
    if not source.exists():
        title = "Missing Image"
        warning_msg = f"The image {instance.image} is missing from the package."
        warnings.append(
            pyfomod.ValidationWarning(
                title,
                warning_msg,
                instance._image,
                critical=True,
            )
        )
    return warnings


def validate_fomod(path: Path):
    """Validate FOMod installer in `path` using `pyfomod.parse.validate`
    and exit with status 1 if warnings are found."""
    warnings = pyfomod.parse(path, lineno=True).validate(
        Root=[lambda x: fomod_image_warnings(path, x)],
    )
    if warnings:
        for warning in warnings:
            typer.secho(
                f"{warning.elem.lineno}: {warning.title} - {warning.msg}\n",
                fg=typer.colors.RED if warning.critical else None,
                err=True,
            )
        raise typer.Exit(code=1)
    else:
        typer.Exit()


def main():
    app()


if __name__ == "__main__":
    app()
